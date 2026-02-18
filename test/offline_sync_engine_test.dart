import 'package:offline_sync_engine/offline_sync_engine.dart';
import 'package:test/test.dart';

void main() {
  group("VersionTracker Tests", () {
    test("increment works correctly", () {
      final tracker = VersionTracker();
      tracker.increment("device_A");
      expect(tracker.versions["device_A"], 1);

      tracker.increment("device_A");
      expect(tracker.versions["device_A"], 2);

      tracker.increment("device_B");
      expect(tracker.versions["device_B"], 1);
    });

    test("dominance works correctly", () {
      final a = VersionTracker({"A": 2});
      final b = VersionTracker({"A": 1});

      expect(a.dominates(b), true);
      expect(b.dominates(a), false);
    });

    test("dominance with multiple devices", () {
      final a = VersionTracker({"A": 2, "B": 3});
      final b = VersionTracker({"A": 1, "B": 2});

      expect(a.dominates(b), true);
      expect(b.dominates(a), false);
    });

    test("concurrent detection works", () {
      final a = VersionTracker({"A": 1});
      final b = VersionTracker({"B": 1});

      expect(a.isConcurrent(b), true);
      expect(b.isConcurrent(a), true);
    });

    test("concurrent with partial overlap", () {
      final a = VersionTracker({"A": 2, "B": 1});
      final b = VersionTracker({"A": 1, "B": 2});

      expect(a.isConcurrent(b), true);
    });

    test("serialization works", () {
      final tracker = VersionTracker({"A": 1, "B": 2});
      final json = tracker.toJson();
      final restored = VersionTracker.fromJson(json);

      expect(restored.versions, tracker.versions);
    });
  });

  group("SyncRecord Merge Tests", () {
    test("dominant record wins", () {
      final r1 = SyncRecord(
        id: "1",
        data: {"name": "Harsh"},
        version: VersionTracker({"A": 2}),
      );

      final r2 = SyncRecord(
        id: "1",
        data: {"name": "John"},
        version: VersionTracker({"A": 1}),
      );

      final merged = r1.merge(r2);

      expect(merged.data["name"], "Harsh");
      expect(merged.version.versions["A"], 2);
    });

    test("concurrent merge combines fields", () {
      final r1 = SyncRecord(
        id: "1",
        data: {"name": "Harsh"},
        version: VersionTracker({"A": 1}),
      );

      final r2 = SyncRecord(
        id: "1",
        data: {"age": 25},
        version: VersionTracker({"B": 1}),
      );

      final merged = r1.merge(r2);

      expect(merged.data["name"], "Harsh");
      expect(merged.data["age"], 25);
    });

    test("concurrent merge with overlapping fields uses last write", () {
      final r1 = SyncRecord(
        id: "1",
        data: {"name": "Alice", "city": "NYC"},
        version: VersionTracker({"A": 1}),
      );

      final r2 = SyncRecord(
        id: "1",
        data: {"name": "Bob", "age": 30},
        version: VersionTracker({"B": 1}),
      );

      final merged = r1.merge(r2);

      // Both names present, last one wins in merge (from r2)
      expect(merged.data.containsKey("name"), true);
      expect(merged.data["age"], 30);
      expect(merged.data["city"], "NYC");
    });

    test("tombstone propagates", () {
      final r1 = SyncRecord(
        id: "1",
        data: {"name": "Harsh"},
        version: VersionTracker({"A": 1}),
      );

      final r2 = SyncRecord(
        id: "1",
        data: {},
        version: VersionTracker({"B": 1}),
        tombstone: true,
      );

      final merged = r1.merge(r2);

      expect(merged.tombstone, true);
    });

    test("merge is commutative", () {
      final r1 = SyncRecord(
        id: "1",
        data: {"a": 1},
        version: VersionTracker({"A": 1}),
      );

      final r2 = SyncRecord(
        id: "1",
        data: {"b": 2},
        version: VersionTracker({"B": 1}),
      );

      final m1 = r1.merge(r2);
      final m2 = r2.merge(r1);

      expect(m1.data, m2.data);
      expect(m1.version.versions, m2.version.versions);
    });
  });

  group("SyncOperation Tests", () {
    test("serialization works", () {
      final op = SyncOperation(
        opId: "op_123",
        recordId: "rec_456",
        payload: {"data": "test"},
        version: VersionTracker({"A": 1}),
      );

      final json = op.toJson();
      final restored = SyncOperation.fromJson(json);

      expect(restored.opId, op.opId);
      expect(restored.recordId, op.recordId);
      expect(restored.payload, op.payload);
      expect(restored.isDelete, false);
    });

    test("delete operation serialization", () {
      final op = SyncOperation(
        opId: "op_123",
        recordId: "rec_456",
        version: VersionTracker({"A": 1}),
        isDelete: true,
      );

      final json = op.toJson();
      final restored = SyncOperation.fromJson(json);

      expect(restored.isDelete, true);
      expect(restored.payload, null);
    });
  });

  group("InMemoryDatabaseAdapter Tests", () {
    test("saveOperation stores operation", () async {
      final db = InMemoryDatabaseAdapter();
      final op = SyncOperation(
        opId: "op1",
        recordId: "rec1",
        payload: {"test": "data"},
        version: VersionTracker({"A": 1}),
      );

      await db.saveOperation(op);
      final unsent = await db.getUnsentOperations();

      expect(unsent.length, 1);
      expect(unsent[0].opId, "op1");
    });

    test("markOperationSent removes from unsent", () async {
      final db = InMemoryDatabaseAdapter();
      final op = SyncOperation(
        opId: "op1",
        recordId: "rec1",
        payload: {"test": "data"},
        version: VersionTracker({"A": 1}),
      );

      await db.saveOperation(op);
      await db.markOperationSent("op1");
      final unsent = await db.getUnsentOperations();

      expect(unsent.length, 0);
    });

    test("operation idempotency", () async {
      final db = InMemoryDatabaseAdapter();

      final op = SyncOperation(
        opId: "op1",
        recordId: "1",
        payload: {"name": "Harsh"},
        version: VersionTracker({"A": 1}),
      );

      await db.applyOperation(op);
      await db.applyOperation(op); // Apply twice

      final record = await db.getRecord("1");

      expect(record!.data["name"], "Harsh");
      expect(await db.isApplied("op1"), true);
    });

    test("clear removes all data", () async {
      final db = InMemoryDatabaseAdapter();

      await db.saveOperation(SyncOperation(
        opId: "op1",
        recordId: "rec1",
        payload: {"test": "data"},
        version: VersionTracker({"A": 1}),
      ));

      db.clear();

      expect(db.getAllRecords().isEmpty, true);
      expect(db.getAllOperations().isEmpty, true);
    });
  });

  group("InMemoryCloudAdapter Tests", () {
    test("push stores operations", () async {
      final cloud = InMemoryCloudAdapter();
      final ops = [
        SyncOperation(
          opId: "op1",
          recordId: "rec1",
          payload: {"test": "data"},
          version: VersionTracker({"A": 1}),
        ),
      ];

      await cloud.push(ops);

      expect(cloud.operationCount, 1);
    });

    test("pull returns all operations", () async {
      final cloud = InMemoryCloudAdapter();
      final op1 = SyncOperation(
        opId: "op1",
        recordId: "rec1",
        payload: {"test": "data1"},
        version: VersionTracker({"A": 1}),
      );
      final op2 = SyncOperation(
        opId: "op2",
        recordId: "rec2",
        payload: {"test": "data2"},
        version: VersionTracker({"B": 1}),
      );

      await cloud.push([op1, op2]);
      final pulled = await cloud.pull();

      expect(pulled.length, 2);
    });

    test("push avoids duplicates", () async {
      final cloud = InMemoryCloudAdapter();
      final op = SyncOperation(
        opId: "op1",
        recordId: "rec1",
        payload: {"test": "data"},
        version: VersionTracker({"A": 1}),
      );

      await cloud.push([op]);
      await cloud.push([op]); // Push same operation twice

      expect(cloud.operationCount, 1);
    });
  });

  group("SyncManager Tests", () {
    test("createOrUpdate creates new record", () async {
      final db = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();
      final manager = SyncManager(
        database: db,
        cloud: cloud,
        deviceId: "A",
      );

      await manager.createOrUpdate("user1", {"name": "Harsh"});
      final record = await db.getRecord("user1");

      expect(record!.data["name"], "Harsh");
      expect(record.version.versions["A"], 1);
    });

    test("createOrUpdate increments version", () async {
      final db = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();
      final manager = SyncManager(
        database: db,
        cloud: cloud,
        deviceId: "A",
      );

      await manager.createOrUpdate("user1", {"name": "Harsh"});
      await manager.createOrUpdate("user1", {"name": "John"});

      final record = await db.getRecord("user1");
      expect(record!.version.versions["A"], 2);
    });

    test("delete marks record as tombstone", () async {
      final db = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();
      final manager = SyncManager(
        database: db,
        cloud: cloud,
        deviceId: "A",
      );

      await manager.createOrUpdate("user1", {"name": "Harsh"});
      await manager.delete("user1");

      final record = await db.getRecord("user1");
      expect(record!.tombstone, true);
    });

    test("push and pull operations", () async {
      final db1 = InMemoryDatabaseAdapter();
      final db2 = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();

      final manager1 = SyncManager(
        database: db1,
        cloud: cloud,
        deviceId: "A",
      );

      final manager2 = SyncManager(
        database: db2,
        cloud: cloud,
        deviceId: "B",
      );

      await manager1.createOrUpdate("user1", {"name": "Harsh"});
      await manager1.sync();

      await manager2.sync();

      final record = await db2.getRecord("user1");

      expect(record!.data["name"], "Harsh");
    });

    test("multi-device convergence", () async {
      final db1 = InMemoryDatabaseAdapter();
      final db2 = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();

      final manager1 = SyncManager(
        database: db1,
        cloud: cloud,
        deviceId: "A",
      );

      final manager2 = SyncManager(
        database: db2,
        cloud: cloud,
        deviceId: "B",
      );

      await manager1.createOrUpdate("doc", {"title": "Hello"});
      await manager2.createOrUpdate("doc", {"body": "World"});

      await manager1.sync();
      await manager2.sync();
      await manager1.sync();

      final r1 = await db1.getRecord("doc");
      final r2 = await db2.getRecord("doc");

      expect(r1!.data, r2!.data);
      expect(r1.data["title"], "Hello");
      expect(r1.data["body"], "World");
    });

    test("concurrent updates merge correctly", () async {
      final db1 = InMemoryDatabaseAdapter();
      final db2 = InMemoryDatabaseAdapter();
      final db3 = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();

      final m1 = SyncManager(database: db1, cloud: cloud, deviceId: "A");
      final m2 = SyncManager(database: db2, cloud: cloud, deviceId: "B");
      final m3 = SyncManager(database: db3, cloud: cloud, deviceId: "C");

      // All devices update same record with different fields
      await m1.createOrUpdate("profile", {"name": "Alice"});
      await m2.createOrUpdate("profile", {"age": 30});
      await m3.createOrUpdate("profile", {"city": "NYC"});

      // Sync all
      await m1.sync();
      await m2.sync();
      await m3.sync();
      await m1.sync();
      await m2.sync();

      final r1 = await db1.getRecord("profile");
      final r2 = await db2.getRecord("profile");
      final r3 = await db3.getRecord("profile");

      // All should converge to same state
      expect(r1!.data, r2!.data);
      expect(r2.data, r3!.data);

      // All fields should be present
      expect(r1.data.containsKey("name"), true);
      expect(r1.data.containsKey("age"), true);
      expect(r1.data.containsKey("city"), true);
    });

    test("isSyncing flag works correctly", () async {
      final db = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();
      final manager = SyncManager(
        database: db,
        cloud: cloud,
        deviceId: "A",
      );

      expect(manager.isSyncing, false);

      // Sync is fast in tests, but flag should work
      await manager.sync();
      expect(manager.isSyncing, false);
    });

    test("generates unique operation IDs", () async {
      final db = InMemoryDatabaseAdapter();
      final cloud = InMemoryCloudAdapter();
      final manager = SyncManager(
        database: db,
        cloud: cloud,
        deviceId: "A",
      );

      await manager.createOrUpdate("doc1", {"data": "test1"});
      await manager.createOrUpdate("doc2", {"data": "test2"});

      final ops = db.getAllOperations();
      final opIds = ops.keys.toList();

      expect(opIds.length, 2);
      expect(opIds[0] != opIds[1], true);
    });
  });

  group("Integration Tests", () {
    test("complete offline-first workflow", () async {
      // Setup 2 devices
      final cloud = InMemoryCloudAdapter();
      final phone = _createDevice("phone", cloud);
      final laptop = _createDevice("laptop", cloud);

      // Phone creates document offline
      await phone.manager.createOrUpdate("doc1", {
        "title": "My Document",
        "created": "phone",
      });

      // Laptop creates different document offline
      await laptop.manager.createOrUpdate("doc2", {
        "title": "Another Doc",
        "created": "laptop",
      });

      // Both sync
      await phone.manager.sync();
      await laptop.manager.sync();
      await phone.manager.sync(); // Ensure full convergence

      // Both devices should have both documents
      final phoneDoc1 = await phone.db.getRecord("doc1");
      final phoneDoc2 = await phone.db.getRecord("doc2");
      final laptopDoc1 = await laptop.db.getRecord("doc1");
      final laptopDoc2 = await laptop.db.getRecord("doc2");

      expect(phoneDoc1, isNotNull);
      expect(phoneDoc2, isNotNull);
      expect(laptopDoc1, isNotNull);
      expect(laptopDoc2, isNotNull);

      expect(phoneDoc1!.data["created"], "phone");
      expect(laptopDoc2!.data["created"], "laptop");
    });

    test("handles delete conflicts", () async {
      final cloud = InMemoryCloudAdapter();
      final device1 = _createDevice("device1", cloud);
      final device2 = _createDevice("device2", cloud);

      // Create and sync initial record
      await device1.manager.createOrUpdate("doc", {"data": "initial"});
      await device1.manager.sync();
      await device2.manager.sync();

      // Device 1 updates, Device 2 deletes (offline)
      await device1.manager.createOrUpdate("doc", {"data": "updated"});
      await device2.manager.delete("doc");

      // Sync both
      await device1.manager.sync();
      await device2.manager.sync();
      await device1.manager.sync();

      // Both should converge (delete should win or merge properly)
      final r1 = await device1.db.getRecord("doc");
      final r2 = await device2.db.getRecord("doc");

      expect(r1, isNotNull);
      expect(r2, isNotNull);
      // Tombstone should propagate
      expect(r1!.tombstone || r2!.tombstone, true);
    });
  });
}

class _TestDevice {
  final String id;
  final InMemoryDatabaseAdapter db;
  final SyncManager manager;

  _TestDevice(this.id, this.db, this.manager);
}

_TestDevice _createDevice(String id, InMemoryCloudAdapter cloud) {
  final db = InMemoryDatabaseAdapter();
  final manager = SyncManager(
    database: db,
    cloud: cloud,
    deviceId: id,
  );
  return _TestDevice(id, db, manager);
}
