abstract class SyncEvent<T> {
  const SyncEvent();
}

class AddData<T> extends SyncEvent<T> {
  final T data;
  const AddData(this.data);
}

class UpdateData<T> extends SyncEvent<T> {
  final T data;
  const UpdateData(this.data);
}

class DeleteData<T> extends SyncEvent<T> {
  final String id;
  const DeleteData(this.id);
}

class StartSync<T> extends SyncEvent<T> {
  const StartSync();
}

class RetryFailed<T> extends SyncEvent<T> {
  const RetryFailed();
}
