import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/user.dart';

class Api {
  static final JsonDecoder _decoder = JsonDecoder();
  static final JsonEncoder _encoder = JsonEncoder();
  static final http.Client httpClient = http.Client();
  static final String baseUrl = (
    App.application.config.env == 'development' ? 'https://test-jselvis.unact.ru/web/' : 'https://selvis.com/web/'
  );

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
    Uri url = Uri.parse(baseUrl + apiMethod + '?' + queryParams);
    http.Request request = http.Request(httpMethod, url);
    if (body != null) request.body = body;

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'SelvisMobile': '${App.application.config.packageInfo.version}',
      'Cookie': _generateCookieHeader()
    });

    try {
      print('API: Started $httpMethod - $url');
      return await _parseResponse(await http.Response.fromStream(await httpClient.send(request)));
    } catch(e) {
      if (e is SocketException || e is http.ClientException || e is HandshakeException) {
        throw ApiConnException();
      } else {
        rethrow;
      }
    }
  }

  static Future<dynamic> _sendRequest(
    String httpMethod,
    String apiMethod,
    Map<String, dynamic> params,
    String body
  ) async {
    return await _sendRawRequest(httpMethod, apiMethod, params, body);
  }

  static Future<dynamic> get(String method, {Map<String, dynamic> params}) async {
    return await _sendRequest('GET', method, params ?? {}, '');
  }

  static Future<dynamic> post(String method, {Map<String, dynamic> params, body}) async {
    return await _sendRequest('POST', method, params ?? {}, _encoder.convert(body));
  }

  static Future<dynamic> _parseResponse(http.Response response) async {
      int statusCode = response.statusCode;
      String body = response.body;

      print('API: Completed ${response.request.method} - ${response.request.url} - $statusCode');
      if (statusCode >= 500) {
        throw ServerException(statusCode);
      }

      if (statusCode >= 400 || statusCode < 200) {
        if (statusCode == 403) {
          throw ApiException('Необходимо заново войти в приложение', statusCode);
        }
        throw ApiException('Ошибка при получении данных', statusCode);
      }

      Map<String, dynamic> parsedBody = body.isEmpty ? Map<String, dynamic>() : _decoder.convert(body);

      if (parsedBody['status'] != 'OK') {
        throw ApiException(parsedBody['message'], statusCode);
      }

      await _updateCookie(response);

      return parsedBody['result'];
  }

  static Future<void> _updateCookie(http.Response response) async {
    String allSetCookie = response.headers['set-cookie'];
    User user = User.currentUser;

    String newDraft = _findInCookieList(allSetCookie, 'anon-draft');
    if (newDraft != 'null') {
      user.lastDraft = _findInCookieList(allSetCookie, 'anon-draft') ?? user.lastDraft;
    }
    user.sessionId = _findInCookieList(allSetCookie, 'JSESSIONID') ?? user.sessionId;
    user.refreshToken = _findInCookieList(allSetCookie, 'remme') ?? user.refreshToken;
    await user.save();
  }

  static String _findInCookieList(String allSetCookie, String cookieKey) {
    if (allSetCookie != null) {
      List<String> setCookies = allSetCookie.split(',');

      for(String setCookie in setCookies) {
        List<String> rawCookies = setCookie.split(';');

        for (String rawCookie in rawCookies) {
          if (rawCookie.isNotEmpty) {
            List<String> keyValue = rawCookie.split('=');

            if (keyValue.length == 2) {
              String key = keyValue[0].trim();
              String value = keyValue[1];

              if (key == cookieKey)
                return value;
            }
          }
        }
      }
    }

    return null;
  }

  static String _generateCookieHeader() {
    User user = User.currentUser;

    return 'JSESSIONID=${user.sessionId};anon-draft=${user.lastDraft};remme=${user.refreshToken}';
  }
}

class ApiException implements Exception {
  String errorMsg;
  int statusCode;

  ApiException(this.errorMsg, this.statusCode);
}

class AuthException extends ApiException {
  AuthException(errorMsg) : super(errorMsg, 401);
}

class ServerException extends ApiException {
  ServerException(statusCode) : super('Нет связи с сервером', statusCode);
}

class ApiConnException extends ApiException {
  ApiConnException() : super('Нет связи', 503);
}
