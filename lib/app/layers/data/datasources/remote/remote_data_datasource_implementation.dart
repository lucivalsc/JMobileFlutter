import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:connect_force_app/app/common/endpoints/endpoints.dart';
import 'package:connect_force_app/app/common/http/http_client.dart';
import 'package:connect_force_app/app/common/models/exception_models.dart';
import 'package:connect_force_app/app/layers/data/datasources/local/banco_datasource_implementation.dart';
import 'package:connect_force_app/app/layers/data/datasources/remote/remote_data_datasource.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class RemoteDataDatasourceImplementation implements IRemoteDataDatasource {
  final Map<String, String> headers = {"Content-Type": "application/json"};
  final IHttpClient client;

  HttpResponse response = HttpResponse(data: null, statusCode: 0);

  RemoteDataDatasourceImplementation(this.client);

  static const url = String.fromEnvironment('DEFINE_API_ADDRESS');
  Map<String, dynamic> parseNestedJson(String jsonString) {
    // Passo 1: Converter `value` de String para Map
    Map<String, dynamic> outerMap = jsonDecode(jsonString);

    // Passo 2: Verificar se `select` é uma String e convertê-lo para Lista<Map<String, dynamic>>
    if (outerMap.containsKey('select') && outerMap['select'] is List) {
      List<dynamic> selectList = outerMap['select'];
      outerMap['select'] = selectList.map((item) {
        if (item is String) {
          return jsonDecode(item); // Converte cada item de String para Map
        }
        return item;
      }).toList();
    }

    return outerMap;
  }

  @override
  Future<List<Object>> datas(List<Object> objects) async {
    final method = objects[0] as String;
    final route = objects[1] as String;
    final payLoad = Map<String, dynamic>.from(objects[2] as Map<String, dynamic>);
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

        await convertByteContentToMap(zippedContentBytes).then((data) {
          for (Map screen in data) {
            if (screen['data'].isNotEmpty) {
              banco.deleteAll(screen['name']);
              if (screen['name'] == 'clientes') {
                banco.dataInsertLista('CLIENTES', screen['data']);
              } else if (screen['name'] == 'produtos') {
                banco.dataInsertLista('PRODUTOS', screen['data']);
              } else {
                banco.dataInsertLista(screen['name'], screen['data']);
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
