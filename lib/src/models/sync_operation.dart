import 'version_tracker.dart';

/// Represents a single sync operation (create, update, or delete)
///
/// Each operation is uniquely identified and carries version information
/// for conflict resolution.
class SyncOperation {
  final String opId;
  final String recordId;
  final Map<String, dynamic>? payload;
  final VersionTracker version;
  final bool isDelete;

  SyncOperation({
    required this.opId,
    required this.recordId,
    required this.version,
    this.payload,
    this.isDelete = false,
  });

  Map<String, dynamic> toJson() => {
        'opId': opId,
        'recordId': recordId,
        'payload': payload,
        'version': version.toJson(),
        'isDelete': isDelete,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      opId: json['opId'] as String,
      recordId: json['recordId'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      version: VersionTracker.fromJson(json['version'] as Map<String, dynamic>),
      isDelete: (json['isDelete'] as bool?) ?? false,
    );
  }

  @override
  String toString() =>
      'SyncOperation(id: $opId, record: $recordId, delete: $isDelete)';
}
