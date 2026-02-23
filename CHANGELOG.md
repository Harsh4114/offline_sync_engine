# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0]
### Added
- **Bloc-like architecture** - New event/state based mental model for predictable and testable data flows.
- `SyncController<T>` - Bloc-like controller managing sync events and states.
- `SyncRepository<T>` - Central repository coordinating local and cloud data sources.
- `SyncLog` - Dedicated sync queue model for operation tracking.
- `LocalDataSource<T>` and `CloudDataSource<T>` - Clean contracts for data access layers.
- `SyncLogStore` - Abstract store for managing sync operations queue.
- `InMemorySyncLogStore` - Ready-to-use in-memory implementation.
- `OfflineSyncEngine<T>` - New facade for simple bloc-like integration.
- Comprehensive examples for Bloc-like architecture patterns.
- Enhanced test suite for new architecture components.

### Changed
- Folder structure reorganization for better modularity and clarity:
  - `bloc_like/` - New top-level directory containing contracts, implementations, models, and services.
  - `models/`, `storage/`, `sync/` - Reorganized for better logical grouping.
- Documentation updated to showcase both traditional and Bloc-like approaches.
- Updated minimum SDK to `>=3.0.0 <4.0.0` to leverage latest Dart features and ensure compatibility with modern Flutter versions.

### Deprecated
- Original `SyncManager` API still functional but superseded by `OfflineSyncEngine<T>` for new projects.

## [3.1.0]

### Changed
- Documentation updates for clarity and accuracy.
- Refined guides and examples to match latest project structure.

## [3.0.0]

### Added
- Clearer inline comments and API docs in core sync files to improve maintainability.
- Additional tests for deterministic concurrent merge behavior and input validation.
- Detailed package review document (`REVIEW_FEEDBACK.md`) for file-by-file improvement planning.

### Changed
- **BREAKING**: strengthened merge determinism for concurrent updates with overlapping fields.
- **BREAKING**: `SyncManager` now rejects empty `deviceId` and empty `recordId` values via `ArgumentError`.
- Improved operation ID generation in `SyncManager` (microseconds + local counter) to reduce collision probability in fast loops.
- README rewritten for cleaner onboarding, production checklist, and clearer adapter contracts.

### Fixed
- Safer vector clock serialization by returning a copied map in `VersionTracker.toJson()`.
- Guard added to prevent merging records with different IDs.

## [2.4.0]

### Changed
- Documentation updates for clarity and accuracy.
- Refined guides and examples to match latest project structure.

## [2.3.0]

### Changed
- Documentation updates for clarity and accuracy.
- Refined guides and examples to match latest project structure.

## [2.2.0]

### Added
- Updated README.md with new repository URL (https://github.com/Harsh4114/offline_sync_engine).
- Added Pub Version badge to README.
- Added MIT License badge to README.
- Enhanced documentation with improved formatting and structure.

### Changed
- Repository, homepage, and documentation URLs updated in pubspec.yaml.
- Improved package metadata for better discoverability.

## [2.1.0]

### Added
- Multi-device example demonstrating cross-device synchronization.
- Delete operation example showcasing tombstone functionality.
- Custom adapters example for production use cases.
- Enhanced test documentation in test/README.md.
- Comprehensive inline code documentation.

### Changed
- Improved test coverage to 30 tests with detailed scenarios.
- Enhanced README with better quick start guide.
- Reorganized examples directory with individual example files.

### Fixed
- Edge cases in vector clock comparison.
- Memory leak in in-memory implementations during long-running operations.

## [2.0.0]

### Added
- **BREAKING**: Built-in implementations (InMemoryDatabaseAdapter and InMemoryCloudAdapter).
- New example directory with practical usage examples.
- PUBLISHING_GUIDE.md for package publication instructions.
- Support for topics in pubspec.yaml (offline, sync, crdt, database, multi-device).
- Comprehensive test suite with 30+ test cases.
- Type-safe operations with full Dart null safety.

### Changed
- **BREAKING**: Restructured library exports for better modularity.
- **BREAKING**: Updated minimum SDK to ">=3.0.0 <4.0.0".
- Improved CRDT merge algorithm for better performance.
- Enhanced documentation with detailed examples and use cases.
- Renamed internal methods for better clarity.

### Fixed
- Conflict resolution issues in concurrent operations.
- Version tracking inconsistencies across devices.
- Idempotency bugs in operation replay.

### Removed
- **BREAKING**: Legacy API methods (deprecated in v1.2.0).

## [1.0.0]

### Added
- Initial release of Offline Sync Engine.
- Core SyncManager class for offline-first data synchronization.
- DatabaseAdapter interface for local storage abstraction.
- CloudAdapter interface for cloud backend abstraction.
- SyncOperation model for operation tracking.
- Basic CRDT-based conflict resolution.
- Automatic sync with push/pull functionality.
- Offline-first architecture.
- Operation-based synchronization.
- Basic test coverage.
- MIT License.
- Initial documentation and README.

[4.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v4.0.0
[3.1.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v3.1.0
[3.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v3.0.0
[2.4.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.4.0
[2.3.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.3.0
[2.2.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.2.0
[2.1.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.1.0
[2.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.0.0
[1.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v1.0.0
