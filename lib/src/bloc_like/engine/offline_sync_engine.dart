import '../controller/sync_controller.dart';
import '../events/sync_event.dart';
import '../states/sync_state.dart';

class OfflineSyncEngine<T> {
  final SyncController<T> _controller;

  OfflineSyncEngine({required SyncController<T> controller})
      : _controller = controller;

  Stream<SyncState> get states => _controller.states;

  SyncState get currentState => _controller.currentState;

  Future<void> add(T data) => _controller.handle(AddData<T>(data));

  Future<void> update(T data) => _controller.handle(UpdateData<T>(data));

  Future<void> delete(String id) => _controller.handle(DeleteData<T>(id));

  Future<void> sync() => _controller.handle(StartSync<T>());

  Future<void> retryFailed() => _controller.handle(RetryFailed<T>());

  Future<void> dispose() => _controller.dispose();
}
