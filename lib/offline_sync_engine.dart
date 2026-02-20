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


// Bloc-like architecture (vNext)
export 'src/bloc_like/contracts/local_data_source.dart';
export 'src/bloc_like/contracts/cloud_data_source.dart';
export 'src/bloc_like/contracts/sync_log_store.dart';
export 'src/bloc_like/contracts/in_memory_sync_log_store.dart';
export 'src/bloc_like/models/sync_log.dart';
export 'src/bloc_like/events/sync_event.dart';
export 'src/bloc_like/states/sync_state.dart';
export 'src/bloc_like/repository/sync_repository.dart';
export 'src/bloc_like/controller/sync_controller.dart';
export 'src/bloc_like/engine/offline_sync_engine.dart';
