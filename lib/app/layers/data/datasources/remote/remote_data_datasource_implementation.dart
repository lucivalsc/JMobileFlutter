import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:jmobileflutter/app/common/http/http_client.dart';
import 'package:jmobileflutter/app/common/models/exception_models.dart';
import 'package:jmobileflutter/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:jmobileflutter/app/layers/data/datasources/remote/remote_data_datasource.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jmobileflutter/app/common/endpoints/endpoints.dart';

class RemoteDataDatasourceImplementation implements IRemoteDataDatasource {
  final Map<String, String> headers = {"Content-Type": "application/json"};
  final IHttpClient client;

  HttpResponse response = HttpResponse(data: null, statusCode: 0);

  RemoteDataDatasourceImplementation(this.client);

  static const url = String.fromEnvironment('DEFINE_API_ADDRESS');

  @override
  Future<List<Object>> datas(List<Object> objects) async {
    final method = objects[0] as String;
    final route = objects[1] as String;
    final payLoad = objects[2] as Map<String, dynamic>;
    final Endpoints endpoints = Endpoints();
    await endpoints.basicAuth();

    final baseUrl = 'http://${endpoints.host}:${endpoints.porta}/$route';
    try {
      HttpResponse response;
      if (method == 'GET') {
        response = await client.get(
          url: baseUrl,
          headers: {
            "Content-Type": "application/json",
            "Connection": "keep-alive",
            'authorization': await endpoints.basicAuth(),
          },
        );
      } else {
        response = await client.post(
          url: baseUrl,
          headers: {
            "Content-Type": "application/json",
            "Connection": "keep-alive",
            'authorization': await endpoints.basicAuth(),
          },
          payload: payLoad,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.data is List) {
          return [response.data];
        }
        if (response.data is String) {
          throw ServerException(
            statusCode: response.statusCode,
            message: 'Erro no servidor',
          );
        } else {
          return [response.data];
        }
      } else {
        throw ServerException(
          statusCode: response.statusCode,
          message: response.data["message"],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Object>> responseType(List<Object> objects) async {
    final branch = jsonDecode(objects[0] as String);
    final rota = objects[1] as String;
    final token = (objects[2] as Map)['access'];
    final method = (objects[3] as String);
    final payload = objects[4] as Map<String, dynamic>;

    final ip = branch['ip'] ?? 'rel.mecgestao.com.br';
    final porta = branch['portaServer'] ?? '443';
    final cnpj = branch['cnpj'].toString().replaceAll('.', '').replaceAll('/', '').replaceAll('-', '');

    final baseUrl = 'http://$ip:$porta/relatorio/$cnpj/$rota';
    try {
      HttpResponse response;
      if (method == 'GET') {
        response = await client.get(
          url: baseUrl,
          headers: Map.from(headers)
            ..addAll({
              "Authorization": "Bearer $token",
            }),
        );
      } else {
        response = await client.post(
          url: baseUrl,
          headers: Map.from(headers)
            ..addAll({
              'Accept-Encoding': 'gzip',
              'Content-Type': 'application/json',
              "Authorization": "Bearer $token",
            }),
          payload: payload,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.data is! List<int>) {
          if (method == 'GET') {
            return [response.data];
          } else {
            // Decodificando a string para obter um Uint8List
            Uint8List bytes = base64Decode(response.data['data']);

            // Convertendo para uma string legível
            // String decodedString = utf8.decode(bytes);
            await openPdf(bytes);
            return [[]];
          }
        } else if (response.data is List<int>) {
          if (method == 'GET') {
            return [
              [response.data]
            ];
          } else {
            // Decodificando a string para obter um Uint8List
            Uint8List bytes = base64Decode(response.data['data']);

            // Convertendo para uma string legível
            // String decodedString = utf8.decode(bytes);
            await openPdf(bytes);
            return [[]];
          }
        } else {
          return [response.data];
        }
      } else {
        throw ServerException(
          statusCode: response.statusCode,
          message: response.data["message"],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  openPdf(Uint8List data) async {
    late Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Plataforma não suportada");
    }

    final fileName = '${DateTime.now().toString()}.pdf';
    final filePath = '${directory!.path}/$fileName';

    File(filePath).writeAsBytesSync(data);

    // Abre o PDF usando a biblioteca open_file
    await OpenFile.open(filePath);
  }

  @override
  Future<List<Object>> synchronous(List<Object> objects) async {
    Databasepadrao banco = Databasepadrao.instance;
    var key = objects[0] as String;
    var idFilial = objects[1] as int;
    var cdUser = objects[2] as int;

    final Endpoints endpoints = Endpoints();
    await endpoints.basicAuth();
    var url = 'http://${endpoints.host}:${endpoints.porta}/ProcessarDados?key=$key&idFilial=$idFilial&cd_user=$cdUser';

    try {
      response = await client.postPdf(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Connection": "keep-alive",
          'authorization': await endpoints.basicAuth(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Processa os dados apenas se o status for 200 (sucesso)
        List<int> zippedContentBytes = [];
        zippedContentBytes.addAll(response.data);

        convertByteContentToMap(zippedContentBytes).then((data) {
          for (Map screen in data) {
            if (screen['data'].isNotEmpty) {
              banco.deleteAll(screen['name']);
              if (screen['name'] == 'clientes') {
                banco.dataInsert('CLIENTES', screen['data']);
              } else if (screen['name'] == 'produtos') {
                banco.dataInsert('PRODUTOS', screen['data']);
              } else {
                banco.dataInsert(screen['name'], screen['data']);
              }
            }
          }
        });
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw ServerException(
          statusCode: response.statusCode,
          message: response.data["error"],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> convertByteContentToMap(List<int> content) async {
    try {
      if (content.isNotEmpty) {
        final archive = ZipDecoder().decodeBytes(content);
        List<Map<String, dynamic>> retorno = [];
        for (int i = 0; i < archive.files.length; i++) {
          var name = archive.files[i].name.replaceAll('.json', '').toLowerCase();
          var datas = jsonDecode(
            (jsonEncode(
              const Utf8Decoder().convert(archive.files[i].content),
            )),
          );
          var itens = jsonDecode(datas);
          var data = jsonDecode(itens['ITENS']);
          retorno.add({
            'name': name,
            'data': data,
          });
        }
        return retorno;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
