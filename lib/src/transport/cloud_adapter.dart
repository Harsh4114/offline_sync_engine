import '../models/sync_operation.dart';

/// Abstract interface for cloud/remote server communication
///
/// Implement this class to connect with your backend API, Firebase,
/// Supabase, or any other cloud service.
///
/// Example implementations are provided in the example folder.
abstract class CloudAdapter {
  /// Push local operations to the cloud/server
  Future<void> push(List<SyncOperation> operations);

  /// Pull new operations from the cloud/server
  Future<List<SyncOperation>> pull();
}
