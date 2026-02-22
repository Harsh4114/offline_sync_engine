import 'dart:async';

import '../events/sync_event_models.dart';
import '../repository/sync_repository_service.dart';
import '../states/sync_state_models.dart';

class SyncController<T> {
  final SyncRepository<T> repository;
  final StreamController<SyncState> _states =
      StreamController<SyncState>.broadcast();

  SyncState _current = const SyncInitial();

  SyncController({required this.repository}) {
    _states.add(_current);
  }

  Stream<SyncState> get states => _states.stream;

  SyncState get currentState => _current;

  Future<void> handle(SyncEvent<T> event) async {
    _emit(const SyncInProgress());

    try {
      if (event is AddData<T>) {
        await repository.add(event.data);
      } else if (event is UpdateData<T>) {
        await repository.update(event.data);
      } else if (event is DeleteData<T>) {
        await repository.delete(event.id);
      } else if (event is StartSync<T>) {
        await repository.syncPending();
      } else if (event is RetryFailed<T>) {
        await repository.retryFailed();
      } else {
        throw UnsupportedError(
            'Unsupported SyncEvent type: ${event.runtimeType}');
      }

      _emit(const SyncSuccess());
    } catch (e) {
      _emit(SyncFailure(e.toString()));
      rethrow;
    }
  }

  void _emit(SyncState state) {
    _current = state;
    _states.add(state);
  }

  Future<void> dispose() async {
    await _states.close();
  }
}
