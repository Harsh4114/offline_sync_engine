# Examples

This folder contains comprehensive examples showing how to use the Offline Sync Engine.

## Running Examples

From the `example` folder, run:

```bash
dart run main.dart                        # Basic usage
dart run multi_device_example.dart        # Multi-device sync
dart run delete_example.dart              # Delete operations
dart run custom_adapters_example.dart     # Custom implementations
```

## Examples Overview

### 1. main.dart - Basic Usage
Demonstrates:
- Setting up the sync manager
- Creating and updating records
- Syncing between two devices
- Automatic conflict resolution

**Key concepts**: Basic CRUD operations, sync flow

### 2. multi_device_example.dart - Multi-Device Sync
Demonstrates:
- Three devices syncing simultaneously
- Concurrent offline updates
- Automatic conflict merging
- Eventual consistency

**Key concepts**: Offline-first, CRDT merge logic

### 3. delete_example.dart - Delete Operations
Demonstrates:
- Deleting records (tombstones)
- How deletes sync across devices
- Filtering tombstoned records

**Key concepts**: Tombstone pattern, soft deletes

### 4. custom_adapters_example.dart - Custom Implementations
Demonstrates:
- Implementing DatabaseAdapter for your database (SQLite, Hive, etc.)
- Implementing CloudAdapter for your backend (REST, Firebase, etc.)
- Pattern for real-world integration

**Key concepts**: Adapter pattern, custom integrations

## Using with Flutter

To use this package in a Flutter app:

```dart
import 'package:offline_sync_engine/offline_sync_engine.dart';

// For quick start/testing, use built-in implementations:
final syncManager = SyncManager(
  database: InMemoryDatabaseAdapter(),
  cloud: InMemoryCloudAdapter(),
  deviceId: 'user_device_123',
);

// For production, implement custom adapters:
final syncManager = SyncManager(
  database: MySQLiteAdapter(),      // Your SQLite implementation
  cloud: MyFirebaseAdapter(),       // Your Firebase implementation
  deviceId: await getDeviceId(),
);
```

## Built-in Implementations

The package includes ready-to-use implementations:

- **InMemoryDatabaseAdapter** - For testing or simple apps
- **InMemoryCloudAdapter** - For testing or demos

## Creating Custom Adapters

See `custom_adapters_example.dart` for the pattern. You need to implement:

1. **DatabaseAdapter** - connects to your local database
   - SQLite (sqflite package)
   - Hive (hive package)
   - SharedPreferences (shared_preferences package)
   - ObjectBox, Isar, Drift, etc.

2. **CloudAdapter** - connects to your backend
   - REST API (http/dio packages)
   - Firebase (firebase packages)
   - Supabase (supabase package)
   - GraphQL, gRPC, etc.

## Need Help?

- Check the main README.md
- Review the test folder for more examples
- See API documentation in source files
