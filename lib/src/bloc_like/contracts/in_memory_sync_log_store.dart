import '../models/sync_log.dart';
import 'sync_log_store.dart';

class InMemorySyncLogStore implements SyncLogStore {
  final List<SyncLog> _logs = [];

  @override
  Future<void> add(SyncLog log) async {
    _logs.add(log);
  }

  @override
  Future<List<SyncLog>> getFailedLogs() async {
    return _logs.where((log) => log.status == SyncStatus.failed).toList();
  }

  @override
  Future<List<SyncLog>> getPendingLogs() async {
    return _logs.where((log) => log.status == SyncStatus.pending).toList();
  }

  @override
  Future<void> markFailed(String logId) async {
    _update(logId, SyncStatus.failed);
  }

  @override
  Future<void> markSynced(String logId) async {
    _update(logId, SyncStatus.synced);
  }

  @override
  Future<void> markSyncing(String logId) async {
    _update(logId, SyncStatus.syncing);
  }

  void _update(String logId, SyncStatus status) {
    final index = _logs.indexWhere((log) => log.id == logId);
    if (index == -1) return;

    _logs[index] = _logs[index].copyWith(status: status);
  }
}
