abstract class IAuthDatasource {
  Future<List<Object>> signIn(List<Object> object);
  Future<List<Object>> alterPassword(List<Object> object);
}
