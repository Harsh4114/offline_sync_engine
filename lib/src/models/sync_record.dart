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
    if (id != other.id) {
      throw ArgumentError('Cannot merge records with different ids: $id and ${other.id}');
    }

    if (version.dominates(other.version)) {
      return this;
    }

    if (other.version.dominates(version)) {
      return other;
    }

    // Concurrent updates → deterministic merge.
    // To keep merge commutative, pick a stable winner for overlapping keys.
    final winner =
        version.compareDeterministically(other.version) >= 0 ? this : other;
    final loser = identical(winner, this) ? other : this;

    final mergedData = <String, dynamic>{...loser.data, ...winner.data};

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
