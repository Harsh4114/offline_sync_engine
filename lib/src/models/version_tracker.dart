/// Tracks versions across multiple devices to detect conflicts
///
/// Uses vector clock algorithm to determine causality and concurrency
/// between operations from different devices.
class VersionTracker {
  final Map<String, int> versions;

  VersionTracker([Map<String, int>? versions]) : versions = versions ?? {};

  /// Increment the version for a specific device
  void increment(String deviceId) {
    versions[deviceId] = (versions[deviceId] ?? 0) + 1;
  }

  /// Check if this version dominates (is newer than) another version
  bool dominates(VersionTracker other) {
    for (final key in other.versions.keys) {
      if ((versions[key] ?? 0) < other.versions[key]!) {
        return false;
      }
    }
    return true;
  }

  /// Check if this version is concurrent (conflicts) with another version
  bool isConcurrent(VersionTracker other) {
    bool greater = false;
    bool smaller = false;

    final keys = {...versions.keys, ...other.versions.keys};

    for (final key in keys) {
      final a = versions[key] ?? 0;
      final b = other.versions[key] ?? 0;

      if (a > b) greater = true;
      if (a < b) smaller = true;
    }

    return greater && smaller;
  }

  Map<String, dynamic> toJson() => versions;

  factory VersionTracker.fromJson(Map<String, dynamic> json) {
    return VersionTracker(Map<String, int>.from(json));
  }

  @override
  String toString() => 'VersionTracker($versions)';
}
