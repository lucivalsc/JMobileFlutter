abstract class IRemoteDataDatasource {
  Future<List<Object>> datas(List<Object> objects);
  Future<List<Object>> responseType(List<Object> objects);
  Future<List<Object>> synchronous(List<Object> objects);
}
