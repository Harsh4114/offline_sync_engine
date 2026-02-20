import '../models/sync_log.dart';

abstract class SyncLogStore {
  Future<void> add(SyncLog log);
  Future<List<SyncLog>> getPendingLogs();
  Future<List<SyncLog>> getFailedLogs();
  Future<void> markSyncing(String logId);
  Future<void> markSynced(String logId);
  Future<void> markFailed(String logId);
}
