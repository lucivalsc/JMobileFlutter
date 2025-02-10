import 'package:connect_force_app/app/common/endpoints/endpoints.dart';
import '../../../../common/http/http_client.dart';
import '../../../../common/models/exception_models.dart';
import 'auth_datasource.dart';

class AuthDatasourceImplementation implements IAuthDatasource {
  final Map<String, String> headers = {"Content-Type": "application/json", "Connection": "keep-alive"};
  final IHttpClient client;
  // final Endpoints endpoints = Endpoints();

  AuthDatasourceImplementation(this.client);

  // static const url = String.fromEnvironment('DEFINE_API_ADDRESS');

  @override
  Future<List<Object>> signIn(List<Object> object) async {
    final Endpoints endpoints = Endpoints();
    await endpoints.basicAuth();
    var username = object[0] as String;
    var password = object[1] as String;

    var url = 'http://${endpoints.host}:${endpoints.porta}/';
    try {
      var response = await client.post(
        url: '${url}Login?Login=$username&Senha=$password',
        headers: {
          "Content-Type": "application/json",
          "Connection": "keep-alive",
          'authorization': await endpoints.basicAuth(),
        },
        payload: {"username": username, "password": password},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.data is List) {
          return [response.data[0]];
        }
        return [response.data];
      } else {
        throw ServerException(
          statusCode: response.statusCode,
          title: 'Falha de Autenticação',
          message: 'Credenciais incorretas!',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Object>> alterPassword(List<Object> object) async {
    // var password = object[0] as String;
    // var loginModel = object[1] as LoginModel;
    try {
      // var ip = 'rel.mecgestao.com.br';
      // var port = '443';

      // var url = 'https://$ip:$port/adm/user/${loginModel.idUsuario}';

      // var response = await client.post(
      //   url: url,
      //   headers: Map.from(headers)
      //     ..addAll({
      //       "Authorization": "Bearer ${loginModel.access}",
      //     }),
      //   payload: {"usu_senha": password},
      // );

      // if (response.statusCode >= 200 && response.statusCode < 300) {
      // return [response.data];
      return [];
      // } else {
      //   throw ServerException(
      //       statusCode: response.statusCode, title: 'Falha de Autenticação', message: 'Credenciais incorretas!');
      // }
    } catch (e) {
      rethrow;
    }
  }

  void login(String username, String password) {}
}
