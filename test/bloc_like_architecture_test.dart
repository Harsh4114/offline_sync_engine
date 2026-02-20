import 'package:offline_sync_engine/offline_sync_engine.dart';
import 'package:test/test.dart';

class _User {
  final String id;
  final String name;

  const _User(this.id, this.name);
}

class _InMemoryLocalUsers implements LocalDataSource<_User> {
  final Map<String, _User> _users = {};

  @override
  Future<void> delete(String id) async {
    _users.remove(id);
  }

  @override
  Future<List<_User>> getAll() async => _users.values.toList();

  @override
  Future<_User?> getById(String id) async => _users[id];

  @override
  Future<void> insert(_User data) async {
    _users[data.id] = data;
  }

  @override
  Future<void> update(_User data) async {
    _users[data.id] = data;
  }
}

class _InMemoryCloudUsers implements CloudDataSource<_User> {
  final Map<String, _User> _users = {};

  @override
  Future<void> create(_User data) async {
    _users[data.id] = data;
  }

  @override
  Future<void> delete(String id) async {
    _users.remove(id);
  }

  @override
  Future<_User?> fetch(String id) async => _users[id];

  @override
  Future<List<_User>> fetchAll() async => _users.values.toList();

  @override
  Future<void> update(_User data) async {
    _users[data.id] = data;
  }
}

void main() {
  test('offline sync engine handles add + sync with bloc-like controller', () async {
    final local = _InMemoryLocalUsers();
    final cloud = _InMemoryCloudUsers();

    final repository = SyncRepository<_User>(
      local: local,
      cloud: cloud,
      logStore: InMemorySyncLogStore(),
      idResolver: (user) => user.id,
    );

    final controller = SyncController<_User>(repository: repository);
    final engine = OfflineSyncEngine<_User>(controller: controller);

    await engine.add(const _User('1', 'Asha'));
    await engine.sync();

    final remote = await cloud.fetch('1');

    expect(remote?.name, 'Asha');
    expect(engine.currentState, isA<SyncSuccess>());

    await engine.dispose();
  });
}
