# Offline Sync Engine

[![Pub Version](https://img.shields.io/pub/v/offline_sync_engine)](https://pub.dev/packages/offline_sync_engine)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub: harsh4114](https://img.shields.io/badge/GitHub-harsh4114-black?logo=github)](https://github.com/harsh4114)
[![Contribute](https://img.shields.io/badge/Contributions-Welcome-green?logo=github)](https://github.com/Harsh4114/offline_sync_engine/issues)

**Author:** [@harsh4114](https://github.com/harsh4114)

---

Offline-first CRDT-based sync engine for Flutter and Dart applications.
It keeps data synchronized across devices with deterministic conflict resolution.

## 🤝 Join the Collaboration

We welcome developers of all levels to contribute! Whether you're looking to:
- 🐛 **Report bugs** or suggest features
- 📝 **Improve documentation**
- 🔧 **Add custom adapters**
- ✨ **Enhance the codebase**
- 🎯 **Share your use cases**

**[Open an Issue](https://github.com/Harsh4114/offline_sync_engine/issues)** or **[Submit a PR](https://github.com/Harsh4114/offline_sync_engine)** to help make this package even better for everyone!

## Features

- 🔄 **Automatic Sync** - Push local operations and pull remote operations.
- 📴 **Offline-First** - Create/update/delete records without network.
- 🔀 **Deterministic Merge** - Concurrent updates converge predictably.
- 📱 **Multi-Device** - Same account on multiple devices stays in sync.
- 🎯 **Operation-Based** - Sync is based on replayable operations.
- 🔢 **Vector Clocks** - Causality tracking across devices.
- ⚡ **Idempotent Apply** - Safe against duplicate operation delivery.
- 🧩 **Adapter-Based** - Plug in your own database and cloud backend.
- ✅ **Type Safe** - Null-safe Dart API.


## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Your App                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     SyncManager                             │
│  - createOrUpdate()                                         │
│  - delete()                                                 │
│  - sync()                                                   │
└────────────┬────────────────────────┬───────────────────────┘
             │                        │
             ▼                        ▼
┌────────────────────────┐  ┌────────────────────────┐
│   DatabaseAdapter      │  │    CloudAdapter        │
│  (Your Implementation) │  │  (Your Implementation) │
│                        │  │                        │
│  - SQLite              │  │  - REST API            │
│  - Hive                │  │  - Firebase            │
│  - SharedPreferences   │  │  - Supabase            │
│  - ObjectBox           │  │  - GraphQL             │
└────────────────────────┘  └────────────────────────┘
````


## Bloc-Like Architecture (New)

The package now supports a Bloc-like mental model for teams that prefer event/state flows with minimal boilerplate.

| Bloc Concept | Package Equivalent |
| --- | --- |
| Event | `SyncEvent<T>` |
| State | `SyncState` |
| Bloc | `SyncController<T>` |
| Repository | `SyncRepository<T>` |
| Data source | `LocalDataSource<T>` + `CloudDataSource<T>` |
| Queue store | `SyncLogStore` |

### Contracts

```dart
abstract class LocalDataSource<T> {
  Future<void> insert(T data);
  Future<void> update(T data);
  Future<void> delete(String id);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
}

abstract class CloudDataSource<T> {
  Future<void> create(T data);
  Future<void> update(T data);
  Future<void> delete(String id);
  Future<T?> fetch(String id);
  Future<List<T>> fetchAll();
}
```

### Sync queue model

```dart
enum SyncOperationType { create, update, delete }
enum SyncStatus { pending, syncing, synced, failed }
```

Each local write appends a `SyncLog`, then `StartSync` replays pending logs using latest-first ordering.

### Events and states

```dart
AddData<T>, UpdateData<T>, DeleteData<T>, StartSync<T>, RetryFailed<T>
SyncInitial, SyncInProgress, SyncSuccess, SyncFailure
```

### Recommended wiring

```dart
final repository = SyncRepository<User>(
  local: localDataSource,
  cloud: cloudDataSource,
  logStore: InMemorySyncLogStore(),
  idResolver: (user) => user.id,
);

final controller = SyncController<User>(repository: repository);
final engine = OfflineSyncEngine<User>(controller: controller);

await engine.add(user);
await engine.sync();
```

### Architecture diagram

```
UI
 ↓
OfflineSyncEngine
 ↓
SyncController
 ↓
SyncRepository
 ↓
LocalDataSource   CloudDataSource
        ↓
     SyncLogStore
```

## Installation

```bash
dart pub add offline_sync_engine
```

or

```bash
flutter pub add offline_sync_engine
```

Your `pubspec.yaml`:

```yaml
dependencies:
  offline_sync_engine: ^latest_version
```

Then run:

```bash
dart pub get
```

or

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:offline_sync_engine/offline_sync_engine.dart';

void main() async {
  final manager = SyncManager(
    database: InMemoryDatabaseAdapter(),
    cloud: InMemoryCloudAdapter(),
    deviceId: 'device_123',
  );

  // Local write (works offline)
  await manager.createOrUpdate('user_1', {
    'name': 'John',
    'email': 'john@example.com',
  });

  // Push + pull sync
  await manager.sync();
}
```

## Core Concepts

### 1) Adapters

You provide two adapters:

1. `DatabaseAdapter`: local persistence (SQLite, Hive, Isar, etc.)
2. `CloudAdapter`: backend transport (REST/Firebase/Supabase/etc.)

For demos/tests, use built-ins:
- `InMemoryDatabaseAdapter`
- `InMemoryCloudAdapter`

### 2) SyncManager

`SyncManager` is the main entry point:

```dart
final manager = SyncManager(
  database: myDatabaseAdapter,
  cloud: myCloudAdapter,
  deviceId: 'unique_device_id',
);

await manager.createOrUpdate('note_1', {'title': 'hello'});
await manager.delete('note_1');
await manager.sync();

final syncing = manager.isSyncing;
```

### 3) Conflict Resolution

The engine uses vector clocks with deterministic merge:

- If one version dominates another, dominant record wins.
- If versions are concurrent, fields are merged deterministically.
- Merge result is stable and commutative for concurrent records.

## Production Checklist (Important)

Before publishing your app with custom adapters:

- [ ] Ensure `saveOperation` + `applyOperation` are durable.
- [ ] Keep operation IDs unique and indexed.
- [ ] Make `isApplied` fast (index/table/set).
- [ ] Use retries/backoff for cloud calls.
- [ ] Add authentication/authorization at transport layer.
- [ ] Add pagination/incremental pull strategy on backend.
- [ ] Add monitoring for sync failures.

## Running Examples

```bash
cd example
dart run main.dart
dart run multi_device_example.dart
dart run delete_example.dart
dart run custom_adapters_example.dart
```

More details: [example/README.md](example/README.md)

## Adapter Contract Notes

### DatabaseAdapter expectations

- `saveOperation` should persist operation before app crash risk.
- `getUnsentOperations` should return unsent operations reliably.
- `markOperationSent` should be idempotent.
- `isApplied` should be idempotency source-of-truth.
- `applyOperation` must be deterministic and safe to replay.

### CloudAdapter expectations

- `push` should accept duplicate deliveries safely.
- `pull` can return already-seen operations; manager handles dedupe via `isApplied`.
- Server ordering should be stable where possible.

## License

MIT License - see [LICENSE](LICENSE).
