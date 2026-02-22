import '../models/sync_operation_model.dart';
import '../models/sync_record_model.dart';
import '../storage/database_adapter_interface.dart';

/// In-memory implementation of DatabaseAdapter
///
/// Suitable for testing, development, or simple apps that don't need persistence.
/// For production apps, implement DatabaseAdapter using SQLite, Hive, or other storage.
class InMemoryDatabaseAdapter implements DatabaseAdapter {
  final Map<String, SyncRecord> _records = {};
  final Map<String, SyncOperation> _operations = {};
  final Set<String> _sentOperations = {};
  final Set<String> _appliedOperations = {};

  @override
  Future<void> saveOperation(SyncOperation operation) async {
    _operations[operation.opId] = operation;
  }

  @override
  Future<List<SyncOperation>> getUnsentOperations() async {
    return _operations.values
        .where((op) => !_sentOperations.contains(op.opId))
        .toList();
  }

  @override
  Future<void> markOperationSent(String opId) async {
    _sentOperations.add(opId);
  }

  @override
  Future<bool> isApplied(String opId) async {
    return _appliedOperations.contains(opId);
  }

  @override
  Future<void> applyOperation(SyncOperation operation) async {
    _appliedOperations.add(operation.opId);

    final existing = _records[operation.recordId];

    final newRecord = SyncRecord(
      id: operation.recordId,
      data: operation.payload ?? {},
      version: operation.version,
      tombstone: operation.isDelete,
    );

    if (existing == null) {
      _records[operation.recordId] = newRecord;
    } else {
      _records[operation.recordId] = existing.merge(newRecord);
    }
  }

  @override
  Future<SyncRecord?> getRecord(String id) async {
    return _records[id];
  }

  /// Get all records (useful for debugging)
  Map<String, SyncRecord> getAllRecords() => Map.from(_records);

  /// Get all operations (useful for debugging)
  Map<String, SyncOperation> getAllOperations() => Map.from(_operations);

  /// Clear all data (useful for testing)
  void clear() {
    _records.clear();
    _operations.clear();
    _sentOperations.clear();
    _appliedOperations.clear();
  }
}
