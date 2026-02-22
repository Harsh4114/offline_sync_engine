import '../models/sync_operation_model.dart';
import '../models/sync_record_model.dart';

/// Abstraction for local persistence used by the sync engine.
///
/// Contract notes for implementers:
/// - Methods should be durable (avoid losing operations on app restart/crash).
/// - [markOperationSent] and [applyOperation] should be idempotent.
/// - [isApplied] should be fast and reliable because it's used for dedupe.
abstract class DatabaseAdapter {
  /// Persists a sync operation locally.
  Future<void> saveOperation(SyncOperation operation);

  /// Returns operations not marked as sent yet.
  Future<List<SyncOperation>> getUnsentOperations();

  /// Marks operation as pushed successfully.
  Future<void> markOperationSent(String opId);

  /// Returns true if operation was already applied locally.
  Future<bool> isApplied(String opId);

  /// Applies operation to local record state.
  Future<void> applyOperation(SyncOperation operation);

  /// Returns a single record by id, or null if missing.
  Future<SyncRecord?> getRecord(String id);
}
