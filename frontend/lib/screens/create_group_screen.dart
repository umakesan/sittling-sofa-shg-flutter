import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/groups_provider.dart';
import '../providers/shared_providers.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

final _villageNamesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(apiClientProvider).fetchVillageNames();
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
  String? _selectedVillage;
  String? _selectedMeetingDay;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedVillage == null) {
      setState(() => _error = 'Please select a village.');
      return;
    }
    if (_selectedMeetingDay == null) {
      setState(() => _error = 'Please select a meeting day.');
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
            villageName: _selectedVillage!,
            meetingDay: _selectedMeetingDay,
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
    final villagesAsync = ref.watch(_villageNamesProvider);

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
                  // Village must be selected first
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
                          onPressed: () => ref.invalidate(_villageNamesProvider),
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
                        : DropdownButtonFormField<String>(
                            value: _selectedVillage,
                            decoration: const InputDecoration(
                              labelText: 'Village',
                              border: OutlineInputBorder(),
                            ),
                            items: villages
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedVillage = v),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Please select a village' : null,
                          ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMeetingDay,
                    decoration: const InputDecoration(
                      labelText: 'Meeting day',
                      border: OutlineInputBorder(),
                    ),
                    items: _weekdays
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (d) => setState(() => _selectedMeetingDay = d),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please select a meeting day' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Group code',
                      hintText: 'e.g. IYARKAI_SL',
                      border: OutlineInputBorder(),
                    ),
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
