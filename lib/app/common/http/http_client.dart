abstract class IHttpClient {
  Future<HttpResponse> get({required String url, Map<String, String>? headers});

  Future<HttpResponse> post({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? payload,
  });

  Future<HttpResponse> post2({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? payload,
  });

  Future<HttpResponse> postPdf({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? payload,
  });

  Future<HttpResponse> patch({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? payload,
  });

  Future<HttpResponse> delete({
    required String url,
    Map<String, String>? headers,
  });
}

class HttpResponse {
  final int statusCode;
  final dynamic data;

  HttpResponse({required this.statusCode, required this.data});
}
