
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class HttpService {
  final String baseUrl;
  late http.Client client;
  HttpService(this.baseUrl) {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    client = IOClient(ioc);
    //client = http.Client();
  }

  Future<http.Response> get(String endpoint,{Map<String, dynamic>? params, Map<String, String>? headers}) async {
    var uri = Uri.parse('$baseUrl$endpoint');

    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    final response = await client.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, dynamic data}) async {
    Map<String, String> finalHeaders = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: finalHeaders,
      body: json.encode(data),
    );
    return _processResponse(response);
  }


  http.Response _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}