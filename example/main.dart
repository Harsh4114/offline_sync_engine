import 'package:offline_sync_engine/offline_sync_engine.dart';

/// Simple example demonstrating basic usage of the Offline Sync Engine
///
/// This example shows how to:
/// - Set up the sync manager with in-memory implementations
/// - Create and update records
/// - Sync data between devices
/// - Handle offline operations
void main() async {
  print('=== Offline Sync Engine - Basic Example ===\n');

  // Create a shared "cloud" that both devices will sync with
  final sharedCloud = InMemoryCloudAdapter();

  // Device 1 setup
  final device1Database = InMemoryDatabaseAdapter();
  final device1 = SyncManager(
    database: device1Database,
    cloud: sharedCloud,
    deviceId: 'device_1',
  );

  // Device 2 setup
  final device2Database = InMemoryDatabaseAdapter();
  final device2 = SyncManager(
    database: device2Database,
    cloud: sharedCloud,
    deviceId: 'device_2',
  );

  print('📱 Device 1: Creating user profile...');
  await device1.createOrUpdate('user_123', {
    'name': 'John Doe',
    'email': 'john@example.com',
  });
  print('✓ User created locally on Device 1\n');

  print('☁️  Device 1: Syncing to cloud...');
  await device1.sync();
  print('✓ Data synced to cloud\n');

  print('📱 Device 2: Syncing from cloud...');
  await device2.sync();
  final user = await device2Database.getRecord('user_123');
  print('✓ Data received on Device 2:');
  print('   Name: ${user?.data['name']}');
  print('   Email: ${user?.data['email']}\n');

  print('📱 Device 2: Updating user age (while offline)...');
  await device2.createOrUpdate('user_123', {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
  });
  print('✓ Age added locally on Device 2\n');

  print('📱 Device 1: Updating user city (while offline)...');
  await device1.createOrUpdate('user_123', {
    'name': 'John Doe',
    'email': 'john@example.com',
    'city': 'New York',
  });
  print('✓ City added locally on Device 1\n');

  print('☁️  Both devices syncing (conflict resolution)...');
  await device1.sync();
  await device2.sync();
  await device1.sync(); // Sync back to ensure convergence
  print('✓ Sync complete\n');

  print('📊 Final state on Device 1:');
  final finalUser1 = await device1Database.getRecord('user_123');
  print('   ${finalUser1?.data}\n');

  print('📊 Final state on Device 2:');
  final finalUser2 = await device2Database.getRecord('user_123');
  print('   ${finalUser2?.data}\n');

  print('✅ Both devices converged to the same state!');
  print('   (Concurrent updates were automatically merged)\n');

  print('=== Example Complete ===');
}
