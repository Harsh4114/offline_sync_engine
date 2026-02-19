# Offline Sync Engine

[![Pub Version](https://img.shields.io/pub/v/offline_sync_engine)](https://pub.dev/packages/offline_sync_engine)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Offline-first CRDT-based sync engine for Flutter and Dart applications.
It keeps data synchronized across devices with deterministic conflict resolution.

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
  offline_sync_engine: ^3.0.0
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
