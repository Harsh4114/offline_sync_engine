import '../models/sync_operation.dart';
import '../models/version_tracker.dart';
import '../storage/database_adapter.dart';
import '../transport/cloud_adapter.dart';

/// Main offline-first sync orchestrator.
///
/// Responsibilities:
/// - create local operations
/// - apply locally for instant offline UX
/// - push unsent operations
/// - pull remote operations and apply idempotently
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

  /// Generates operation IDs with timestamp + local counter.
  String _generateOpId() {
    _opCounter += 1;
    return '${deviceId}_${DateTime.now().microsecondsSinceEpoch}_$_opCounter';
  }

  /// Creates or updates a record.
  ///
  /// Operation is persisted locally and synced on next cycle.
  Future<void> createOrUpdate(
      String recordId, Map<String, dynamic> data) async {
    if (recordId.trim().isEmpty) {
      throw ArgumentError.value(recordId, 'recordId', 'must not be empty');
    }

    final record = await database.getRecord(recordId);

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

  /// Deletes a record by applying a tombstone operation.
  Future<void> delete(String recordId) async {
    if (recordId.trim().isEmpty) {
      throw ArgumentError.value(recordId, 'recordId', 'must not be empty');
    }

    final record = await database.getRecord(recordId);

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

  /// Runs one sync cycle.
  ///
  /// Safe to call repeatedly. If already syncing, call returns.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1) Push local unsent operations.
      final unsent = await database.getUnsentOperations();
      if (unsent.isNotEmpty) {
        await cloud.push(unsent);

        for (final op in unsent) {
          await database.markOperationSent(op.opId);
        }
      }

      // 2) Pull remote operations and apply unseen ones.
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

  bool get isSyncing => _isSyncing;
}
