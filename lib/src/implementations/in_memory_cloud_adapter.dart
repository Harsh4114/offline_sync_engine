import '../models/sync_operation_model.dart';
import '../transport/cloud_adapter_interface.dart';

/// In-memory implementation of CloudAdapter that simulates a cloud server
///
/// Suitable for testing, development, or demos. For production, implement
/// CloudAdapter to connect with your actual backend API.
class InMemoryCloudAdapter implements CloudAdapter {
  final List<SyncOperation> _serverOperations = [];

  @override
  Future<void> push(List<SyncOperation> operations) async {
    for (final op in operations) {
      // Avoid duplicates
      if (!_serverOperations.any((o) => o.opId == op.opId)) {
        _serverOperations.add(op);
      }
    }
  }

  @override
  Future<List<SyncOperation>> pull() async {
    return List.from(_serverOperations);
  }

  /// Get all operations stored in the "cloud" (useful for debugging)
  List<SyncOperation> getAllOperations() => List.from(_serverOperations);

  /// Clear all data (useful for testing)
  void clear() {
    _serverOperations.clear();
  }

  /// Get operation count (useful for debugging)
  int get operationCount => _serverOperations.length;
}
