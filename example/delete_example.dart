import 'package:offline_sync_engine/offline_sync_engine.dart';

/// Example showing delete operations (tombstones) and how they sync
void main() async {
  print('=== Delete Operations Example ===\n');

  final cloud = InMemoryCloudAdapter();

  final device1Db = InMemoryDatabaseAdapter();
  final device1 = SyncManager(
    database: device1Db,
    cloud: cloud,
    deviceId: 'device_1',
  );

  final device2Db = InMemoryDatabaseAdapter();
  final device2 = SyncManager(
    database: device2Db,
    cloud: cloud,
    deviceId: 'device_2',
  );

  // Create some records
  print('📝 Creating records...');
  await device1.createOrUpdate('doc_1', {'title': 'Document 1'});
  await device1.createOrUpdate('doc_2', {'title': 'Document 2'});
  await device1.createOrUpdate('doc_3', {'title': 'Document 3'});
  await device1.sync();
  await device2.sync();
  print('✓ 3 documents created and synced\n');

  var records = device2Db.getAllRecords();
  print('Device 2 has ${records.length} documents\n');

  // Delete one document
  print('🗑️  Device 1: Deleting doc_2...');
  await device1.delete('doc_2');
  await device1.sync();
  print('✓ Delete synced to cloud\n');

  // Device 2 syncs the delete
  print('📱 Device 2: Syncing...');
  await device2.sync();
  final doc2 = await device2Db.getRecord('doc_2');
  print('✓ Delete received');
  print('   doc_2 tombstone: ${doc2?.tombstone}\n');

  records = device2Db.getAllRecords();
  final activeRecords = records.values.where((r) => !r.tombstone).length;
  print('📊 Final state:');
  print('   Total records: ${records.length}');
  print('   Active records: $activeRecords');
  print('   Deleted records: ${records.length - activeRecords}\n');

  print('=== Example Complete ===');
}
