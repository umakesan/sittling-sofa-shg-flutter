import '../api/api_client.dart';
import '../database/local_db.dart';
import '../models/group.dart';

abstract interface class GroupRepository {
  Future<List<Group>> getAll();
  Future<List<Group>> refreshFromServer();
}

class LocalGroupRepository implements GroupRepository {
  LocalGroupRepository({required LocalDb db, required ApiClient api})
      : _db = db,
        _api = api;

  final LocalDb _db;
  final ApiClient _api;

  @override
  Future<List<Group>> getAll() => _db.getGroups();

  @override
  Future<List<Group>> refreshFromServer() async {
    final groups = await _api.fetchGroups();
    await _db.upsertGroups(groups);
    return groups;
  }
}

class ApiGroupRepository implements GroupRepository {
  ApiGroupRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<Group>> getAll() => _api.fetchGroups();

  @override
  Future<List<Group>> refreshFromServer() => _api.fetchGroups();
}
