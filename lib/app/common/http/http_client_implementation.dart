import "dart:async";
import "dart:convert";
import 'dart:io';

import "package:http/http.dart" as http;
import "package:http/http.dart";
import 'package:http/io_client.dart';

import "../models/exception_models.dart";
import "http_client.dart";

class TrustAllCertificates {
  static http.Client sslClient() {
    var ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true; // Aceita todos os certificados
      };
    http.Client client = IOClient(ioClient);
    return client;
  }
}

class HttpClientImplementation implements IHttpClient {
  final client = TrustAllCertificates.sslClient();
  late Response response;

  @override
  Future<HttpResponse> get({required String url, Map<String, String>? headers}) async {
    try {
      response =
          await client.get(Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')), headers: headers).timeout(
                const Duration(seconds: 10),
              );
      return HttpResponse(
        statusCode: response.statusCode,
        data: json.decode(
          response.body,
        ),
      );
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }

  @override
  Future<HttpResponse> post({required String url, Map<String, String>? headers, Map<String, dynamic>? payload}) async {
    try {
      response = await client
          .post(
            Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')),
            headers: headers,
            body: payload != null ? json.encode(payload) : null,
          )
          .timeout(const Duration(seconds: 10));
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body.isNotEmpty
            ? json.decode(response.body)
            : {"success": true, "message": "Erro no servidor", "falha": true},
      );
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }

  @override
  Future<HttpResponse> post2({required String url, Map<String, String>? headers, Map<String, dynamic>? payload}) async {
    try {
      response = await client
          .post(
            Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')),
            headers: headers,
            body: payload != null ? json.encode(payload) : null,
          )
          .timeout(const Duration(seconds: 10));
      return HttpResponse(
        statusCode: response.statusCode,
        data: null,
      );
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }

  @override
  Future<HttpResponse> postPdf(
      {required String url, Map<String, String>? headers, Map<String, dynamic>? payload}) async {
    try {
      response = await client
          .post(
            Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')),
            headers: headers,
            body: payload != null ? json.encode(payload) : null,
          )
          .timeout(const Duration(seconds: 10));
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.bodyBytes,
      );
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }

  @override
  Future<HttpResponse> patch({required String url, Map<String, String>? headers, Map<String, dynamic>? payload}) async {
    try {
      response = await client
          .patch(
            Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')),
            headers: headers,
            body: payload != null ? json.encode(payload) : null,
          )
          .timeout(const Duration(seconds: 10));
      return HttpResponse(
        statusCode: response.statusCode,
        data: json.decode(response.body),
      );
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }

  @override
  Future<HttpResponse> delete({required String url, Map<String, String>? headers}) async {
    try {
      response = await client
          .delete(Uri.parse(url.replaceAll(':NULL', '').replaceAll(':null', '')), headers: headers)
          .timeout(const Duration(seconds: 10));
      return HttpResponse(
          statusCode: response.statusCode,
          data: response.body.isNotEmpty
              ? json.decode(response.body)
              : {"success": true, "message": "Erro no servidor", "falha": true});
    } on TimeoutException {
      throw const ServerException(
        message: 'Timeout ao tentar conectar ao servidor.',
        title: 'Timeout',
        statusCode: -1,
      );
    } on FormatException catch (e) {
      // Captura a exceção FormatException e passa a mensagem de erro para o ServerException
      throw ServerException(
        statusCode: response.statusCode,
        message: e.source,
        title: 'Erro de formatação',
      );
    } catch (e) {
      // Captura outras exceções e passa a mensagem de erro para o ServerException
      throw ServerException(
        message: e.toString(),
        title: 'Erro',
        statusCode: -1,
      );
    }
  }
}
