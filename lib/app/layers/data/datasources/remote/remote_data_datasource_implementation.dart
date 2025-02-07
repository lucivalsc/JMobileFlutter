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
    final user = objects[0] as String;
    final password = objects[1] as String;
    final dataini = objects[2] as String;
    final datafin = objects[3] as String;
    final branch = jsonDecode(objects[4] as String);
    final rota = objects[5] as String;
    final ano = objects[6] as int;

    final filialini = branch['filialPadrao'].toString();
    final ip = branch['ip'] ?? 'rel.mecgestao.com.br';
    final porta = branch['portaServer'] ?? '443';
    final cnpj = branch['cnpj'].toString().replaceAll('.', '').replaceAll('/', '').replaceAll('-', '');

    final token = (objects[7] as Map)['access'];
    final method = objects.length == 9 ? (objects[8] as String) : 'POST';

    Map<String, dynamic> payLoad = {};
    if (ano > 0) {
      payLoad = {
        "user": user,
        "ano": ano,
        "filial": filialini,
      };
    } else {
      payLoad = {
        "user": user,
        "password": password,
        "filial": filialini,
        "dataini": dataini,
        "datafin": datafin,
      };
    }
    final baseUrl = 'https://$ip:$porta/relatorio/$cnpj/$rota';
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
              "Authorization": "Bearer $token",
            }),
          payload: payLoad,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300 && response.data['success'] == true) {
        return [response.data];
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

    final baseUrl = 'https://$ip:$porta/relatorio/$cnpj/$rota';
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
    final Endpoints endpoints = Endpoints();
    await endpoints.basicAuth();
    Databasepadrao banco = Databasepadrao.instance;
    var url = 'http://${endpoints.host}:${endpoints.porta}/ProcessarDados?key="start"&idFilial=${-1}&cd_user=${-1}';

    try {
      response = await client.postPdf(
        url: '${url}api/addresses',
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
        return [response.data];
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
