abstract class IStorageDatasource {
  Future<Map> loadDataToSend(List<Object> objects);
  Future<void> saveDataToSend(List<Object> objects);
  Future<void> deleteDataToSend(List<Object> objects);
  // Future<List<Object>> saveDataStorage(List<Object> objects);
  // Future<List<Object>> loadDataStorage(List<Object> objects);
}
