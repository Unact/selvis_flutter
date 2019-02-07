import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:selvis_flutter/app/app.dart';

class DadataApi {
  static final JsonDecoder _decoder = JsonDecoder();
  static final JsonEncoder _encoder = JsonEncoder();
  static final http.Client httpClient = http.Client();
  static final String apiUrl = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/';

  static String _writeParam(String key, String value) {
    return Uri.encodeQueryComponent(key) + '=' + Uri.encodeQueryComponent(value);
  }

  static Future<dynamic> _sendRawRequest(
    String httpMethod,
    String apiMethod,
    Map<String, dynamic> params,
    [String body]
  ) async {
    String queryParams = params.entries.map<String>(
      (MapEntry<String, dynamic> entry) => _writeParam(entry.key, entry.value.toString())
    ).join('&');
    Uri url = Uri.parse(apiUrl + apiMethod + '?' + queryParams);
    http.Request request = http.Request(httpMethod, url);
    if (body != null) request.body = body;

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token ${App.application.config.dadataApiKey}'
    });

    try {
      print('Dadata API: Started $url');
      return await _parseResponse(await http.Response.fromStream(await httpClient.send(request)));
    } catch(e) {
      if (e is SocketException || e is http.ClientException || e is HandshakeException) {
        throw DadataApiException(400);
      } else {
        rethrow;
      }
    }
  }

  static Future<dynamic> get(String method, {Map<String, dynamic> params}) async {
    return await _sendRawRequest('GET', method, params ?? {}, '');
  }

  static Future<dynamic> post(String method, {Map<String, dynamic> params, body}) async {
    return await _sendRawRequest('POST', method, params ?? {}, _encoder.convert(body));
  }

  static Future<dynamic> _parseResponse(http.Response response) async {
      int statusCode = response.statusCode;
      Map<String, dynamic> parsedBody = _decoder.convert(response.body);

      print('API: Completed ${response.request.method} - ${response.request.url} - $statusCode');
      if (statusCode >= 400 || statusCode < 200) {
        throw DadataApiException(statusCode);
      }

      return parsedBody;
  }
}

class DadataApiException implements Exception {
  String errorMsg = 'Ошибка при получении данных';
  int statusCode;

  DadataApiException(this.statusCode);
}
