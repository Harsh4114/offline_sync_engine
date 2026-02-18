import '../models/sync_operation.dart';
import '../models/sync_record.dart';

/// Abstract interface for local database operations
///
/// Implement this class to connect your local database (SQLite, Hive,
/// SharedPreferences, etc.) with the offline sync engine.
///
/// Example implementations are provided in the example folder.
abstract class DatabaseAdapter {
  /// Save a sync operation to the local database
  Future<void> saveOperation(SyncOperation operation);

  /// Get all operations that haven't been sent to the cloud yet
  Future<List<SyncOperation>> getUnsentOperations();

  /// Mark an operation as successfully sent to the cloud
  Future<void> markOperationSent(String opId);

  /// Check if an operation has already been applied locally
  Future<bool> isApplied(String opId);

  /// Apply an operation to update the local data
  Future<void> applyOperation(SyncOperation operation);

  /// Get a specific record by ID
  Future<SyncRecord?> getRecord(String id);
}
