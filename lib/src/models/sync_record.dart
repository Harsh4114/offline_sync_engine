import 'version_tracker.dart';

/// Represents a synchronized record with merge/conflict resolution behavior.
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

  /// Merges this record with [other] deterministically.
  ///
  /// Rules:
  /// 1) Dominant version wins.
  /// 2) Concurrent versions are merged with stable tie-break for overlaps.
  /// 3) Tombstone propagates if either side is deleted.
  SyncRecord merge(SyncRecord other) {
    if (id != other.id) {
      throw ArgumentError(
        'Cannot merge records with different ids: $id and ${other.id}',
      );
    }

    if (version.dominates(other.version)) {
      return this;
    }

    if (other.version.dominates(version)) {
      return other;
    }

    // Concurrent updates:
    // choose a stable winner so merge remains deterministic/commutative.
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
