abstract class LocalDataSource<T> {
  Future<void> insert(T data);
  Future<void> update(T data);
  Future<void> delete(String id);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
}
