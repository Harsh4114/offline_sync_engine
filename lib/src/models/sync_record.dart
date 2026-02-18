import 'version_tracker.dart';

/// Represents a synchronized data record with conflict resolution capabilities
///
/// Records can be merged deterministically when concurrent updates occur.
class SyncRecord {
  final String id;
  Map<String, dynamic> data;
  VersionTracker version;
  bool tombstone;

  SyncRecord({
    required this.id,
    required this.data,
    required this.version,
    this.tombstone = false,
  });

  /// Merges this record with another, resolving conflicts deterministically
  ///
  /// If one version dominates, that version wins.
  /// If versions are concurrent, data is merged.
  SyncRecord merge(SyncRecord other) {
    if (version.dominates(other.version)) {
      return this;
    }

    if (other.version.dominates(version)) {
      return other;
    }

    // Concurrent updates → deterministic merge
    // Last-write-wins for each field, combined fields from both
    final mergedData = {...data, ...other.data};

    final mergedVersion = VersionTracker({
      ...version.versions,
      ...other.version.versions,
    });

    return SyncRecord(
      id: id,
      data: mergedData,
      version: mergedVersion,
      tombstone: tombstone || other.tombstone,
    );
  }

  @override
  String toString() =>
      'SyncRecord(id: $id, tombstone: $tombstone, data: $data)';
}
