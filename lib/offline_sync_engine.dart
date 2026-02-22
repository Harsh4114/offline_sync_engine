/// Offline-first CRDT-based sync engine for Flutter and Dart
///
/// Provides automatic conflict resolution and multi-device data synchronization.
library offline_sync_engine;

// Core Models
export 'src/models/version_tracker_model.dart';
export 'src/models/sync_record_model.dart';
export 'src/models/sync_operation_model.dart';

// Adapters (implement these for your database and cloud)
export 'src/storage/database_adapter_interface.dart';
export 'src/transport/cloud_adapter_interface.dart';

// Main Sync Manager
export 'src/sync/sync_manager_service.dart';

// Built-in Implementations (ready to use)
export 'src/implementations/in_memory_database_adapter.dart';
export 'src/implementations/in_memory_cloud_adapter.dart';


// Bloc-like architecture (vNext)
export 'src/bloc_like/contracts/local_data_source_contract.dart';
export 'src/bloc_like/contracts/cloud_data_source_contract.dart';
export 'src/bloc_like/contracts/sync_log_store_contract.dart';
export 'src/bloc_like/implementations/in_memory_sync_log_store_impl.dart';
export 'src/bloc_like/models/sync_log_model.dart';
export 'src/bloc_like/events/sync_event_models.dart';
export 'src/bloc_like/states/sync_state_models.dart';
export 'src/bloc_like/repository/sync_repository_service.dart';
export 'src/bloc_like/controller/sync_controller_service.dart';
export 'src/bloc_like/engine/offline_sync_engine_facade.dart';
