import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/village_option.dart';
import '../providers/groups_provider.dart';
import '../providers/shared_providers.dart';

final _villagesProvider = FutureProvider<List<VillageOption>>((ref) {
  return ref.read(apiClientProvider).fetchVillages();
});

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  VillageOption? _selectedVillage;
  int? _selectedDate;
  bool _saving = false;
  String? _error;
  bool _codeEdited = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_autoFillCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _autoFillCode() {
    if (_codeEdited) return;
    _updateCode();
  }

  void _updateCode() {
    if (_codeEdited) return;
    final name = _nameController.text.trim();
    final date = _selectedDate;
    if (name.isEmpty || date == null) return;

    final abbr = _selectedVillage?.abbreviation;
    _codeController.text = (abbr != null && abbr.isNotEmpty)
        ? '$name - $abbr - $date'
        : '$name - $date';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedVillage == null) {
      setState(() => _error = 'Please select a village.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Please select a meeting date.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).createGroup(
            name: _nameController.text.trim(),
            code: _codeController.text.trim(),
            villageName: _selectedVillage!.name,
            meetingDay: _selectedDate.toString(),
          );
      ref.invalidate(groupsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created.')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      setState(() => _error = 'Failed to create group. The code may already be in use.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final villagesAsync = ref.watch(_villagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Village
                  villagesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Could not load villages. Please try again.',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(_villagesProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                    data: (villages) => villages.isEmpty
                        ? const Text(
                            'No villages found. Create a village first.',
                            style: TextStyle(color: Colors.orange),
                          )
                        : DropdownButtonFormField<VillageOption>(
                            value: _selectedVillage,
                            decoration: const InputDecoration(
                              labelText: 'Village',
                              border: OutlineInputBorder(),
                            ),
                            items: villages
                                .map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v.name),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedVillage = v;
                                _updateCode();
                              });
                            },
                            validator: (_) =>
                                _selectedVillage == null ? 'Please select a village' : null,
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Meeting date
                  DropdownButtonFormField<int>(
                    value: _selectedDate,
                    decoration: const InputDecoration(
                      labelText: 'Meeting date',
                      hintText: 'Day of month the group meets',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                    ),
                    onChanged: (d) {
                      setState(() {
                        _selectedDate = d;
                        _updateCode();
                      });
                    },
                    validator: (_) =>
                        _selectedDate == null ? 'Please select a meeting date' : null,
                  ),
                  const SizedBox(height: 16),

                  // Group name
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g. Thamarai',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Group code (auto-filled, editable)
                  TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      labelText: 'Group code',
                      hintText: 'Auto-filled from name, village & date',
                      border: const OutlineInputBorder(),
                      suffixIcon: _codeEdited
                          ? IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Reset to auto-generated',
                              onPressed: () {
                                setState(() => _codeEdited = false);
                                _updateCode();
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() => _codeEdited = true),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(_saving ? 'Creating…' : 'Create group'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
