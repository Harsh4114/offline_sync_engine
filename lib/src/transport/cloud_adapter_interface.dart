import '../models/sync_operation_model.dart';

/// Abstraction for remote/cloud transport.
///
/// Contract notes:
/// - [push] should tolerate retries/duplicate operations.
/// - [pull] may return already-seen operations; local dedupe is expected.
abstract class CloudAdapter {
  /// Pushes local operations to server.
  Future<void> push(List<SyncOperation> operations);

  /// Pulls operations from server.
  Future<List<SyncOperation>> pull();
}
