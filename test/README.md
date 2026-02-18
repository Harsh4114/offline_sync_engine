# Tests

Comprehensive test suite for the Offline Sync Engine.

## Running Tests

From the package root directory:

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# Run specific test file
dart test test/offline_sync_engine_test.dart
```

## Test Coverage

The test suite covers:

### 1. VersionTracker Tests
- Increment functionality
- Dominance detection (causality)
- Concurrency detection (conflicts)
- Serialization/deserialization
- Multi-device version tracking

### 2. SyncRecord Tests
- Merge logic for dominant records
- Concurrent merge with field combination
- Tombstone propagation
- Merge commutativity
- Deterministic conflict resolution

### 3. SyncOperation Tests
- Operation creation
- Serialization/deserialization
- Delete operations
- Idempotency

### 4. InMemoryDatabaseAdapter Tests
- Operation storage
- Unsent operation tracking
- Operation marking as sent
- Apply operation logic
- Duplicate prevention
- Clear functionality

### 5. InMemoryCloudAdapter Tests
- Push operations to cloud
- Pull operations from cloud
- Duplicate prevention
- Operation counting

### 6. SyncManager Tests
- Create/update operations
- Version incrementing
- Delete operations (tombstones)
- Push/pull synchronization
- Multi-device convergence
- Concurrent update handling
- Sync flag management
- Unique ID generation

### 7. Integration Tests
- Complete offline-first workflow
- Multi-device scenarios
- Delete conflict handling
- Real-world usage patterns

## Test Patterns

### Testing Custom Adapters

When implementing custom adapters, follow these test patterns:

```dart
import 'package:test/test.dart';
import 'package:offline_sync_engine/offline_sync_engine.dart';
import 'my_custom_adapter.dart';

void main() {
  group('MyCustomDatabaseAdapter', () {
    late MyCustomDatabaseAdapter adapter;

    setUp(() {
      adapter = MyCustomDatabaseAdapter();
    });

    tearDown(() async {
      await adapter.close();
    });

    test('saves and retrieves operations', () async {
      final op = SyncOperation(
        opId: 'test_op',
        recordId: 'test_rec',
        payload: {'test': 'data'},
        version: VersionTracker({'A': 1}),
      );

      await adapter.saveOperation(op);
      final unsent = await adapter.getUnsentOperations();

      expect(unsent.length, 1);
      expect(unsent[0].opId, 'test_op');
    });

    // Add more tests...
  });
}
```

### Testing Multi-Device Sync

```dart
test('three devices sync correctly', () async {
  final cloud = InMemoryCloudAdapter();
  
  final device1 = SyncManager(
    database: InMemoryDatabaseAdapter(),
    cloud: cloud,
    deviceId: 'device_1',
  );
  
  final device2 = SyncManager(
    database: InMemoryDatabaseAdapter(),
    cloud: cloud,
    deviceId: 'device_2',
  );
  
  // Test scenario...
});
```

## Test Data

Test data should be deterministic and representative:

```dart
// Good: Simple, clear test data
{'name': 'Test User', 'age': 30}

// Good: Tests specific scenarios
{'field_with_conflict': 'value', 'timestamp': 12345}

// Avoid: Random or unpredictable data in tests
{'name': Random().nextInt(1000).toString()}
```

## Debugging Failed Tests

If tests fail:

1. Check test output for specific assertion failures
2. Add debug prints to see state:
   ```dart
   print('Record data: ${record.data}');
   print('Version: ${record.version}');
   ```
3. Run single test in isolation:
   ```bash
   dart test test/offline_sync_engine_test.dart --name "specific test name"
   ```
4. Check that adapters are properly initialized
5. Verify sync order (may need multiple sync rounds for convergence)

## CI/CD Integration

For GitHub Actions:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: dart test
```

## Performance Tests

While not included in the main test suite, you can add performance tests:

```dart
test('handles large number of operations', () async {
  final db = InMemoryDatabaseAdapter();
  final manager = SyncManager(
    database: db,
    cloud: InMemoryCloudAdapter(),
    deviceId: 'perf_test',
  );

  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < 1000; i++) {
    await manager.createOrUpdate('doc_$i', {'index': i});
  }
  
  stopwatch.stop();
  print('1000 operations took: ${stopwatch.elapsedMilliseconds}ms');
  
  expect(stopwatch.elapsedMilliseconds, lessThan(5000));
});
```

## Need Help?

- Review test examples in `offline_sync_engine_test.dart`
- Check example implementations in the `example/` folder
- See main README.md for architecture details
