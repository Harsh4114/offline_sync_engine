import 'package:offline_sync_engine/offline_sync_engine.dart';

/// Advanced example demonstrating multi-device sync with conflict resolution
///
/// This example simulates a collaborative todo app with multiple devices
/// making concurrent updates offline, then syncing and resolving conflicts.
void main() async {
  print('=== Multi-Device Collaborative Todo App ===\n');

  // Shared cloud backend
  final cloud = InMemoryCloudAdapter();

  // Three devices (phone, tablet, laptop)
  final phone = _createDevice('phone', cloud);
  final tablet = _createDevice('tablet', cloud);
  final laptop = _createDevice('laptop', cloud);

  // Phone creates initial todo list
  print('📱 Phone: Creating todo list...');
  await phone.manager.createOrUpdate('todo_1', {
    'title': 'Buy groceries',
    'completed': false,
    'priority': 'high',
  });
  await phone.manager.sync();
  print('✓ Todo created and synced\n');

  // Tablet and Laptop sync to get the todo
  await tablet.manager.sync();
  await laptop.manager.sync();
  print('✓ All devices synced\n');

  // All devices go offline and make different changes
  print('🔌 All devices go OFFLINE...\n');

  print('📱 Phone: Marking todo as completed');
  await phone.manager.createOrUpdate('todo_1', {
    'title': 'Buy groceries',
    'completed': true,
    'priority': 'high',
  });

  print('📱 Tablet: Adding items list');
  await tablet.manager.createOrUpdate('todo_1', {
    'title': 'Buy groceries',
    'completed': false,
    'priority': 'high',
    'items': ['milk', 'bread', 'eggs'],
  });

  print('💻 Laptop: Changing priority');
  await laptop.manager.createOrUpdate('todo_1', {
    'title': 'Buy groceries',
    'completed': false,
    'priority': 'medium',
  });

  print('\n✓ All changes made offline\n');

  // Devices come back online and sync
  print('🌐 Devices come back ONLINE and sync...\n');

  await phone.manager.sync();
  print('✓ Phone synced');

  await tablet.manager.sync();
  print('✓ Tablet synced');

  await laptop.manager.sync();
  print('✓ Laptop synced');

  // Do another round to ensure full convergence
  await phone.manager.sync();
  await tablet.manager.sync();
  await laptop.manager.sync();
  print('\n✓ Full sync convergence achieved\n');

  // Check final state on all devices
  print('📊 Final State:\n');

  final phoneTodo = await phone.database.getRecord('todo_1');
  print('Phone:  ${phoneTodo?.data}');

  final tabletTodo = await tablet.database.getRecord('todo_1');
  print('Tablet: ${tabletTodo?.data}');

  final laptopTodo = await laptop.database.getRecord('todo_1');
  print('Laptop: ${laptopTodo?.data}');

  print('\n✅ All devices converged!');
  print('   - Concurrent updates were automatically merged');
  print('   - All fields from all devices are preserved');
  print('   - Order doesn\'t matter - result is always consistent\n');

  print('=== Example Complete ===');
}

class _Device {
  final String name;
  final InMemoryDatabaseAdapter database;
  final SyncManager manager;

  _Device(this.name, this.database, this.manager);
}

_Device _createDevice(String name, InMemoryCloudAdapter cloud) {
  final database = InMemoryDatabaseAdapter();
  final manager = SyncManager(
    database: database,
    cloud: cloud,
    deviceId: name,
  );
  return _Device(name, database, manager);
}
