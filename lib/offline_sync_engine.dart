/// Offline-first CRDT-based sync engine for Flutter and Dart
///
/// Provides automatic conflict resolution and multi-device data synchronization.
library offline_sync_engine;

// Core Models
export 'src/models/version_tracker.dart';
export 'src/models/sync_record.dart';
export 'src/models/sync_operation.dart';

// Adapters (implement these for your database and cloud)
export 'src/storage/database_adapter.dart';
export 'src/transport/cloud_adapter.dart';

// Main Sync Manager
export 'src/sync/sync_manager.dart';

// Built-in Implementations (ready to use)
export 'src/implementations/in_memory_database.dart';
export 'src/implementations/in_memory_cloud.dart';
