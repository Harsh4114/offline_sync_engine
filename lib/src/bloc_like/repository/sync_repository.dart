import '../contracts/cloud_data_source.dart';
import '../contracts/local_data_source.dart';
import '../contracts/sync_log_store.dart';
import '../models/sync_log.dart';

typedef EntityIdResolver<T> = String Function(T value);

class SyncRepository<T> {
  final LocalDataSource<T> local;
  final CloudDataSource<T> cloud;
  final SyncLogStore logStore;
  final EntityIdResolver<T> idResolver;

  SyncRepository({
    required this.local,
    required this.cloud,
    required this.logStore,
    required this.idResolver,
  });

  Future<void> add(T data) async {
    final id = idResolver(data);
    await local.insert(data);
    await logStore.add(
      SyncLog(
        id: _logId(),
        entityId: id,
        operation: SyncOperationType.create,
        timestamp: DateTime.now(),
        status: SyncStatus.pending,
      ),
    );
  }

  Future<void> update(T data) async {
    final id = idResolver(data);
    await local.update(data);
    await logStore.add(
      SyncLog(
        id: _logId(),
        entityId: id,
        operation: SyncOperationType.update,
        timestamp: DateTime.now(),
        status: SyncStatus.pending,
      ),
    );
  }

  Future<void> delete(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Identifier must not be empty or whitespace');
    }

    await local.delete(trimmedId);
    await logStore.add(
      SyncLog(
        id: _logId(),
        entityId: trimmedId,
        operation: SyncOperationType.delete,
        timestamp: DateTime.now(),
        status: SyncStatus.pending,
      ),
    );
  }

  Future<void> syncPending() async {
    final logs = await logStore.getPendingLogs();
    await _syncLogs(logs);
  }

  Future<void> retryFailed() async {
    final logs = await logStore.getFailedLogs();
    await _syncLogs(logs);
  }

  Future<void> _syncLogs(List<SyncLog> logs) async {
    final sorted = [...logs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final log in sorted) {
      try {
        await logStore.markSyncing(log.id);
        await _execute(log);
        await logStore.markSynced(log.id);
      } catch (_) {
        await logStore.markFailed(log.id);
      }
    }
  }

  Future<void> _execute(SyncLog log) async {
    switch (log.operation) {
      case SyncOperationType.create:
        final data = await local.getById(log.entityId);
        if (data == null) {
          throw StateError(
            'Local data not found for create operation on entityId ${log.entityId}',
          );
        }
        await cloud.create(data);
        return;
      case SyncOperationType.update:
        final data = await local.getById(log.entityId);
        if (data == null) {
          // Treat missing local data as an error so the log is marked as failed.
          throw StateError('Cannot update: local entity not found for id ${log.entityId}');
        }
        await cloud.update(data);
        return;
      case SyncOperationType.delete:
        await cloud.delete(log.entityId);
        return;
    }
  }

  String _logId() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return 'sync_log_$micros';
  }
}
