/// Tracks versions across multiple devices to detect conflicts.
///
/// This is a vector clock:
/// - key   => deviceId
/// - value => monotonic counter for that device
class VersionTracker {
  final Map<String, int> versions;

  VersionTracker([Map<String, int>? versions]) : versions = versions ?? {};

  /// Increments the version for [deviceId].
  void increment(String deviceId) {
    versions[deviceId] = (versions[deviceId] ?? 0) + 1;
  }

  /// Returns true if this clock dominates [other] (>= on all entries in other).
  bool dominates(VersionTracker other) {
    for (final key in other.versions.keys) {
      if ((versions[key] ?? 0) < other.versions[key]!) {
        return false;
      }
    }
    return true;
  }

  /// Returns true if this clock and [other] are concurrent.
  /// Concurrent means neither dominates the other.
  bool isConcurrent(VersionTracker other) {
    var greater = false;
    var smaller = false;

    final keys = {...versions.keys, ...other.versions.keys};

    for (final key in keys) {
      final a = versions[key] ?? 0;
      final b = other.versions[key] ?? 0;

      if (a > b) greater = true;
      if (a < b) smaller = true;
    }

    return greater && smaller;
  }

  /// Returns an immutable JSON-safe copy of the current vector clock.
  Map<String, dynamic> toJson() => Map<String, int>.from(versions);

  factory VersionTracker.fromJson(Map<String, dynamic> json) {
    return VersionTracker(Map<String, int>.from(json));
  }

  @override
  String toString() => 'VersionTracker($versions)';

  /// Provides a stable ordering when two clocks are concurrent.
  ///
  /// Returns:
  /// - positive if this tracker should win
  /// - negative if [other] should win
  /// - zero if equivalent
  int compareDeterministically(VersionTracker other) {
    final keys = <String>{...versions.keys, ...other.versions.keys}.toList()
      ..sort();

    for (final key in keys) {
      final a = versions[key] ?? 0;
      final b = other.versions[key] ?? 0;
      if (a != b) {
        return a.compareTo(b);
      }
    }

    return 0;
  }
}
