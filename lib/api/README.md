# API Integration Guide

This guide explains how to connect your banking app to a backend API.

## Architecture Overview

The app uses a **service abstraction pattern** that allows you to easily switch between mock data (for development) and real API calls (for production).

### Key Components

1. **ApiService** (`lib/api/services/api_service.dart`) - Abstract interface defining all API methods
2. **MockApiService** (`lib/api/services/mock_api_service.dart`) - Mock implementation using local storage
3. **RealApiService** (`lib/api/services/real_api_service.dart`) - Real API implementation
4. **ApiClient** (`lib/api/api_client.dart`) - HTTP client wrapper with error handling
5. **ApiConfig** (`lib/config/api_config.dart`) - Configuration for API endpoints and settings
6. **ApiServiceFactory** (`lib/api/api_service_factory.dart`) - Factory to create the appropriate service

## Quick Start

### Step 1: Configure API Settings

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'https://api.yourbank.com/v1';
  
  // Set to false when ready to use real backend
  static const bool useMockData = false;
  
  // Update endpoints if your backend uses different paths
  static const String loginEndpoint = '/auth/login';
  // ... other endpoints
}
```

### Step 2: Update Endpoints (if needed)

If your backend uses different endpoint paths, update them in `ApiConfig`:

```dart
static const String loginEndpoint = '/api/v1/auth/login';
static const String accountsEndpoint = '/api/v1/accounts';
// etc.
```

### Step 3: Test the Connection

1. Set `useMockData = false` in `ApiConfig`
2. Update `baseUrl` to your backend URL
3. Run the app and test authentication
4. Check logs for any connection errors

## Switching Between Mock and Real API

The app automatically uses the correct service based on `ApiConfig.useMockData`:

- **`useMockData = true`** → Uses `MockApiService` (local storage)
- **`useMockData = false`** → Uses `RealApiService` (HTTP requests)

No code changes needed in providers or services!

## API Response Format

Your backend should return responses in this format:

### Success Response
```json
{
  "data": {
    // Your data here
  },
  "message": "Success message (optional)",
  "status": "success"
}
```

### Error Response
```json
{
  "message": "Error message",
  "statusCode": 400,
  "errors": {
    "field": ["Error detail"]
  }
}
```

## Authentication

The API client automatically includes authentication tokens in requests:

1. After login, save the token to secure storage
2. The `ApiClient` will automatically add it to request headers as `Authorization: Bearer <token>`
3. Update `ApiClient._getAuthToken()` to retrieve from your secure storage

### Example: Saving Token After Login

In `RealApiService.login()`:

```dart
if (response.success && response.data != null) {
  final token = response.data!['token'];
  // Save to secure storage
  await secureStorage.write(key: 'auth_token', value: token);
}
```

## Error Handling

All API methods return `ApiResponse<T>` which includes:

- `success` - Boolean indicating success/failure
- `data` - The response data (if successful)
- `message` - Error or success message
- `statusCode` - HTTP status code
- `errors` - Validation errors (if any)

### Example Usage

```dart
final response = await _apiService.getAccounts();
if (response.success && response.data != null) {
  final accounts = response.data!;
  // Use accounts
} else {
  // Handle error
  print('Error: ${response.message}');
}
```

## Adding New API Endpoints

1. Add the method to `ApiService` interface
2. Implement in both `MockApiService` and `RealApiService`
3. Update `ApiConfig` with the endpoint path
4. Use in your providers/services

### Example: Adding a New Endpoint

**1. Add to ApiService:**
```dart
Future<ApiResponse<YourModel>> getYourData(String id);
```

**2. Implement in MockApiService:**
```dart
@override
Future<ApiResponse<YourModel>> getYourData(String id) async {
  await _simulateDelay();
  // Return mock data
  return ApiResponse.success(mockData);
}
```

**3. Implement in RealApiService:**
```dart
@override
Future<ApiResponse<YourModel>> getYourData(String id) async {
  final response = await _apiClient.get<Map<String, dynamic>>(
    '${ApiConfig.yourDataEndpoint}/$id',
    fromJson: (json) => json,
  );
  
  if (response.success && response.data != null) {
    return ApiResponse.success(YourModel.fromJson(response.data!));
  }
  
  return ApiResponse.error(response.message ?? 'Failed to get data');
}
```

**4. Add endpoint to ApiConfig:**
```dart
static const String yourDataEndpoint = '/your-data';
```

## Testing

### Testing with Mock Data
- Set `useMockData = true`
- All data comes from local storage
- No network calls needed

### Testing with Real API
- Set `useMockData = false`
- Update `baseUrl` to your test server
- Monitor network requests

## Troubleshooting

### Connection Errors
- Check `baseUrl` is correct
- Verify backend is running
- Check network connectivity
- Review timeout settings in `ApiConfig`

### Authentication Errors
- Verify token is being saved correctly
- Check token format matches backend expectations
- Ensure token is included in headers

### Response Parsing Errors
- Verify response format matches expected structure
- Check model `fromJson` methods
- Review error logs for details

## Best Practices

1. **Always handle errors** - Check `response.success` before using data
2. **Use type-safe models** - Convert JSON to Dart models
3. **Handle network failures** - Show user-friendly error messages
4. **Cache when appropriate** - Store frequently accessed data locally
5. **Test both implementations** - Verify mock and real API work correctly

## Next Steps

1. Update `ApiConfig.baseUrl` with your backend URL
2. Set `useMockData = false` when ready
3. Test all API endpoints
4. Implement token refresh if needed
5. Add request/response logging for debugging

## Support

For issues or questions:
- Check API response format matches expected structure
- Verify all endpoints are correctly configured
- Review error messages in logs
- Test with mock data first, then switch to real API

