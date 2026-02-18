import 'package:offline_sync_engine/offline_sync_engine.dart';

/// Example showing how to implement custom database and cloud adapters
///
/// This demonstrates the pattern for creating your own adapters for:
/// - SQLite, Hive, SharedPreferences, etc. (for DatabaseAdapter)
/// - REST API, Firebase, Supabase, etc. (for CloudAdapter)
void main() async {
  print('=== Custom Adapter Implementation Example ===\n');

  final customCloud = CustomHttpCloudAdapter('https://api.example.com');
  final customDb = CustomSQLiteDatabaseAdapter('app.db');

  final syncManager = SyncManager(
    database: customDb,
    cloud: customCloud,
    deviceId: 'user_device_123',
  );

  print('✓ Sync manager created with custom adapters\n');

  print('📝 Creating a document...');
  await syncManager.createOrUpdate('note_1', {
    'title': 'Meeting Notes',
    'content': 'Discuss project timeline',
    'tags': ['work', 'important'],
  });
  print('✓ Document created\n');

  print('☁️  Syncing to cloud...');
  await syncManager.sync();
  print('✓ Data synced\n');

  print('This example shows the pattern for implementing custom adapters.');
  print('See the class implementations below for details.\n');

  print('=== Example Complete ===');
}

/// Example custom HTTP-based cloud adapter
///
/// In a real app, you'd use http, dio, or other packages to make actual requests
class CustomHttpCloudAdapter implements CloudAdapter {
  final String baseUrl;
  final List<SyncOperation> _localCache = []; // Simulating for example

  CustomHttpCloudAdapter(this.baseUrl);

  @override
  Future<void> push(List<SyncOperation> operations) async {
    print('   → POST $baseUrl/sync/push');
    print('   → Sending ${operations.length} operations');

    // In a real implementation:
    // final response = await http.post(
    //   Uri.parse('$baseUrl/sync/push'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(operations.map((op) => op.toJson()).toList()),
    // );

    // For this example, just cache locally
    _localCache.addAll(operations);
  }

  @override
  Future<List<SyncOperation>> pull() async {
    print('   → GET $baseUrl/sync/pull');
    print('   → Received ${_localCache.length} operations');

    // In a real implementation:
    // final response = await http.get(Uri.parse('$baseUrl/sync/pull'));
    // final data = jsonDecode(response.body) as List;
    // return data.map((json) => SyncOperation.fromJson(json)).toList();

    return List.from(_localCache);
  }
}

/// Example custom SQLite-based database adapter
///
/// In a real app, you'd use sqflite or drift packages
class CustomSQLiteDatabaseAdapter implements DatabaseAdapter {
  final String dbPath;
  final Map<String, SyncRecord> _records = {}; // Simulating for example
  final Map<String, SyncOperation> _operations = {};
  final Set<String> _sent = {};
  final Set<String> _applied = {};

  CustomSQLiteDatabaseAdapter(this.dbPath);

  @override
  Future<void> saveOperation(SyncOperation operation) async {
    print('   → INSERT INTO operations ...');

    // In a real implementation:
    // await db.insert('operations', operation.toJson());

    _operations[operation.opId] = operation;
  }

  @override
  Future<List<SyncOperation>> getUnsentOperations() async {
    print('   → SELECT * FROM operations WHERE sent = 0');

    // In a real implementation:
    // final result = await db.query('operations', where: 'sent = ?', whereArgs: [0]);
    // return result.map((row) => SyncOperation.fromJson(row)).toList();

    return _operations.values.where((op) => !_sent.contains(op.opId)).toList();
  }

  @override
  Future<void> markOperationSent(String opId) async {
    print('   → UPDATE operations SET sent = 1 WHERE id = $opId');

    // In a real implementation:
    // await db.update('operations', {'sent': 1}, where: 'id = ?', whereArgs: [opId]);

    _sent.add(opId);
  }

  @override
  Future<bool> isApplied(String opId) async {
    return _applied.contains(opId);
  }

  @override
  Future<void> applyOperation(SyncOperation operation) async {
    print('   → Applying operation ${operation.opId}');
    _applied.add(operation.opId);

    final existing = _records[operation.recordId];
    final newRecord = SyncRecord(
      id: operation.recordId,
      data: operation.payload ?? {},
      version: operation.version,
      tombstone: operation.isDelete,
    );

    _records[operation.recordId] =
        existing == null ? newRecord : existing.merge(newRecord);
  }

  @override
  Future<SyncRecord?> getRecord(String id) async {
    return _records[id];
  }
}
