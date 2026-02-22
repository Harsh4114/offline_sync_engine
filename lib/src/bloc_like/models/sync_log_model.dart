enum SyncOperationType { create, update, delete }

enum SyncStatus { pending, syncing, synced, failed }

class SyncLog {
  final String id;
  final String entityId;
  final SyncOperationType operation;
  final DateTime timestamp;
  final SyncStatus status;

  const SyncLog({
    required this.id,
    required this.entityId,
    required this.operation,
    required this.timestamp,
    required this.status,
  });

  SyncLog copyWith({
    String? id,
    String? entityId,
    SyncOperationType? operation,
    DateTime? timestamp,
    SyncStatus? status,
  }) {
    return SyncLog(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
