import '../models/sync_operation.dart';
import '../models/version_tracker.dart';
import '../storage/database_adapter.dart';
import '../transport/cloud_adapter.dart';

/// Main sync engine that manages offline-first data synchronization
///
/// Handles conflict resolution using CRDT (Conflict-free Replicated Data Type)
/// algorithms with vector clocks for deterministic merging across multiple devices.
///
/// Usage:
/// ```dart
/// final syncManager = SyncManager(
///   database: myDatabaseAdapter,
///   cloud: myCloudAdapter,
///   deviceId: "device_123",
/// );
///
/// await syncManager.createOrUpdate("user1", {"name": "John"});
/// await syncManager.sync();
/// ```
class SyncManager {
  final DatabaseAdapter database;
  final CloudAdapter cloud;
  final String deviceId;

  bool _isSyncing = false;
  int _opCounter = 0;

  SyncManager({
    required this.database,
    required this.cloud,
    required this.deviceId,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError.value(deviceId, 'deviceId', 'must not be empty');
    }
  }

  String _generateOpId() {
    _opCounter += 1;
    return '${deviceId}_${DateTime.now().microsecondsSinceEpoch}_$_opCounter';
  }

  /// Create or update a record with the given data
  ///
  /// This operation is recorded and will be synced to the cloud on next sync.
  Future<void> createOrUpdate(
      String recordId, Map<String, dynamic> data) async {
    if (recordId.trim().isEmpty) {
      throw ArgumentError.value(recordId, 'recordId', 'must not be empty');
    }
    final record = await database.getRecord(recordId);

    // Create a copy of the version to avoid modifying the existing record
    final version = record?.version != null
        ? VersionTracker(Map.from(record!.version.versions))
        : VersionTracker();
    version.increment(deviceId);

    final op = SyncOperation(
      opId: _generateOpId(),
      recordId: recordId,
      payload: data,
      version: version,
    );

    await database.saveOperation(op);
    await database.applyOperation(op);
  }

  /// Delete a record (marks it as tombstone)
  ///
  /// The deletion is recorded and will be synced to cloud on next sync.
  Future<void> delete(String recordId) async {
    if (recordId.trim().isEmpty) {
      throw ArgumentError.value(recordId, 'recordId', 'must not be empty');
    }
    final record = await database.getRecord(recordId);
    // Create a copy of the version to avoid modifying the existing record
    final version = record?.version != null
        ? VersionTracker(Map.from(record!.version.versions))
        : VersionTracker();
    version.increment(deviceId);

    final op = SyncOperation(
      opId: _generateOpId(),
      recordId: recordId,
      version: version,
      isDelete: true,
    );

    await database.saveOperation(op);
    await database.applyOperation(op);
  }

  /// Synchronize with cloud: push local changes and pull remote changes
  ///
  /// This operation is idempotent and can be called multiple times safely.
  /// Conflicts are automatically resolved using CRDT merge logic.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Push local changes to cloud
      final unsent = await database.getUnsentOperations();
      if (unsent.isNotEmpty) {
        await cloud.push(unsent);

        for (final op in unsent) {
          await database.markOperationSent(op.opId);
        }
      }

      // Pull remote changes from cloud
      final incoming = await cloud.pull();

      for (final op in incoming) {
        if (!await database.isApplied(op.opId)) {
          await database.applyOperation(op);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if a sync is currently in progress
  bool get isSyncing => _isSyncing;
}
