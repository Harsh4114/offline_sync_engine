abstract class SyncState {
  const SyncState();
}

class SyncInitial extends SyncState {
  const SyncInitial();
}

class SyncInProgress extends SyncState {
  const SyncInProgress();
}

class SyncSuccess extends SyncState {
  const SyncSuccess();
}

class SyncFailure extends SyncState {
  final String message;
  const SyncFailure(this.message);
}
