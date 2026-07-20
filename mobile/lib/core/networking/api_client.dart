import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:turota_mobile/core/config/api_config.dart';
import 'package:turota_mobile/core/networking/api_exception.dart';
import 'package:turota_mobile/core/storage/token_storage.dart';

class ApiClient {
  ApiClient(this._tokenStorage, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _httpClient;

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };

    final token = await _tokenStorage.getToken();
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    // Attempt to parse RFC 7807 ProblemDetails
    Map<String, dynamic>? errorBody;
    try {
      if (response.body.isNotEmpty) {
        errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Ignored
    }

    if (errorBody != null) {
      throw ApiException.fromJson(response.statusCode, errorBody);
    }

    throw ApiException(
      statusCode: response.statusCode,
      errorCode: 'HTTP_${response.statusCode}',
      message:
          'Sunucu ile iletişimde bir hata oluştu (${response.statusCode}).',
      traceId: '',
    );
  }

  Future<dynamic> get(String path) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = await _getHeaders();

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        errorCode: 'NETWORK_ERROR',
        message: 'İnternet bağlantınızı kontrol edin.',
        traceId: '',
      );
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = await _getHeaders();

      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        errorCode: 'NETWORK_ERROR',
        message: 'İnternet bağlantınızı kontrol edin.',
        traceId: '',
      );
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = await _getHeaders();

      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        errorCode: 'NETWORK_ERROR',
        message: 'İnternet bağlantınızı kontrol edin.',
        traceId: '',
      );
    }
  }
}
