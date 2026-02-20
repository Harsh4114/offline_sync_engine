abstract class CloudDataSource<T> {
  Future<void> create(T data);
  Future<void> update(T data);
  Future<void> delete(String id);
  Future<T?> fetch(String id);
  Future<List<T>> fetchAll();
}
