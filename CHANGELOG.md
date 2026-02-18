# Changelog

All notable changes to the Offline Sync Engine project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-02-18

### Changed
- Documentation updates for clarity and accuracy
- Refined guides and examples to match latest project structure

## [2.2.0] - 2026-02-18

### Added
- Updated README.md with new repository URL (https://github.com/Harsh4114/offline_sync_engine)
- Added Pub Version badge to README
- Added MIT License badge to README
- Enhanced documentation with improved formatting and structure

### Changed
- Repository, homepage, and documentation URLs updated in pubspec.yaml
- Improved package metadata for better discoverability

## [2.1.0] - 2026-02-10

### Added
- Multi-device example demonstrating cross-device synchronization
- Delete operation example showcasing tombstone functionality
- Custom adapters example for production use cases
- Enhanced test documentation in test/README.md
- Comprehensive inline code documentation

### Changed
- Improved test coverage to 30 tests with detailed scenarios
- Enhanced README with better quick start guide
- Reorganized examples directory with individual example files

### Fixed
- Edge cases in vector clock comparison
- Memory leak in in-memory implementations during long-running operations

## [2.0.0] - 2026-01-25

### Added
- **BREAKING**: Built-in implementations (InMemoryDatabaseAdapter and InMemoryCloudAdapter)
- New example directory with practical usage examples
- PUBLISHING_GUIDE.md for package publication instructions
- Support for topics in pubspec.yaml (offline, sync, crdt, database, multi-device)
- Comprehensive test suite with 30+ test cases
- Type-safe operations with full Dart null safety

### Changed
- **BREAKING**: Restructured library exports for better modularity
- **BREAKING**: Updated minimum SDK to ">=3.0.0 <4.0.0"
- Improved CRDT merge algorithm for better performance
- Enhanced documentation with detailed examples and use cases
- Renamed internal methods for better clarity

### Fixed
- Conflict resolution issues in concurrent operations
- Version tracking inconsistencies across devices
- Idempotency bugs in operation replay

### Removed
- **BREAKING**: Legacy API methods (deprecated in v1.2.0)



## [1.0.0] - 2025-10-15

### Added
- Initial release of Offline Sync Engine
- Core SyncManager class for offline-first data synchronization
- DatabaseAdapter interface for local storage abstraction
- CloudAdapter interface for cloud backend abstraction
- SyncOperation model for operation tracking
- Basic CRDT-based conflict resolution
- Automatic sync with push/pull functionality
- Offline-first architecture
- Operation-based synchronization
- Basic test coverage
- MIT License
- Initial documentation and README

### Features
- Create and update records with automatic versioning
- Sync local changes to cloud
- Pull remote changes from cloud
- Deterministic conflict resolution
- Device-specific operation tracking
- Adapter pattern for custom implementations

---

## Version History Summary

- **v2.x.x**: Production-ready with built-in implementations, comprehensive examples, and enhanced testing
- **v1.x.x**: Core functionality with CRDT-based sync, vector clocks, and adapter interfaces

For upgrade guides between major versions, see the [README.md](README.md) documentation.

[2.2.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.2.0
[2.1.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.1.0
[2.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v2.0.0
[1.2.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v1.2.0
[1.1.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v1.1.0
[1.0.0]: https://github.com/Harsh4114/offline_sync_engine/releases/tag/v1.0.0