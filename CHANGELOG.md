## 2.0.0

**BREAKING CHANGES** - Major refactor with better naming and usability

### Changed
- **Renamed files for clarity:**
  - `CRDTSyncEngine` → `SyncManager`
  - `LocalStore` → `DatabaseAdapter`
  - `RemoteTransport` → `CloudAdapter`
  - `CRDTRecord` → `SyncRecord`
  - `Operation` → `SyncOperation`
  - `VectorClock` → `VersionTracker`

### Added
- Built-in implementations:
  - `InMemoryDatabaseAdapter` - Ready-to-use in-memory database
  - `InMemoryCloudAdapter` - Ready-to-use in-memory cloud
- Comprehensive examples:
  - Basic usage example
  - Multi-device sync example
  - Delete operations example
  - Custom adapters implementation guide
- Enhanced documentation:
  - Detailed README with architecture diagrams
  - Example folder with README
  - Test folder with README and comprehensive test coverage
- Better API documentation with dartdocs
- More intuitive naming throughout

### Improved
- Test coverage significantly increased
- Better error messages
- More efficient operation ID generation
- Enhanced merge logic documentation

### Migration Guide
If upgrading from 1.x:

```dart
// Old (1.x)
final engine = CRDTSyncEngine(
  store: myLocalStore,
  transport: myTransport,
  deviceId: "device_123",
);

// New (2.x)
final manager = SyncManager(
  database: myDatabaseAdapter,
  cloud: myCloudAdapter,
  deviceId: "device_123",
);

// Rename your adapter classes:
// LocalStore → DatabaseAdapter
// RemoteTransport → CloudAdapter

// Update imports:
// VectorClock → VersionTracker
// CRDTRecord → SyncRecord
// Operation → SyncOperation
```

## 1.0.0

- Initial stable release
- CRDT-based offline sync engine
- Vector clock support
- Deterministic merge
- Multi-device convergence
- Operation idempotency
- Full test coverage

