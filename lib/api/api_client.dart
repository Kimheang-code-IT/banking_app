import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'models/api_response.dart';
import 'models/api_error.dart';
import '../services/storage_service.dart';

/// HTTP API Client
/// 
/// Handles all HTTP requests to the backend API
/// Includes authentication, error handling, and response parsing
class ApiClient {
  final StorageService _storageService = StorageService();
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Get authentication token from storage
  Future<String?> _getAuthToken() async {
    // In a real app, you'd get the token from secure storage
    // For now, we'll use a placeholder
    final user = await _storageService.getUser();
    return user?['token'] as String?;
  }

  /// Get default headers
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': ApiConfig.contentType,
      'Accept': ApiConfig.acceptHeader,
    };

    if (includeAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConfig.baseUrl}$endpoint';
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;
      final body = response.body;

      if (statusCode >= 200 && statusCode < 300) {
        if (body.isEmpty) {
          return ApiResponse.success(null as T, statusCode: statusCode);
        }

        final jsonData = jsonDecode(body);
        
        if (fromJson != null) {
          final data = fromJson(jsonData);
          return ApiResponse.success(data, statusCode: statusCode);
        }
        
        return ApiResponse.success(jsonData as T, statusCode: statusCode);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle error response
  ApiResponse<T> _handleErrorResponse<T>(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final error = ApiError.fromJson(jsonData);
      
      return ApiResponse.error(
        error.message,
        statusCode: response.statusCode,
        errors: error.details,
      );
    } catch (e) {
      String message;
      switch (response.statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized. Please login again.';
          break;
        case 403:
          message = 'Forbidden';
          break;
        case 404:
          message = 'Resource not found';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
        default:
          message = 'An error occurred (${response.statusCode})';
      }
      
      return ApiResponse.error(message, statusCode: response.statusCode);
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      var url = _buildUrl(endpoint);
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParams).toString();
      }

      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          'Request timeout. Please check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          'Request timeout. Please check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          'Request timeout. Please check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          'Request timeout. Please check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          'Request timeout. Please check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

