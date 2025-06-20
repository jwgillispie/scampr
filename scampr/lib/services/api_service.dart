import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use environment variable or fallback to localhost for development
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.response?.data}');
        handler.next(error);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _authToken = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });

      if (response.data['access_token'] != null) {
        await _saveToken(response.data['access_token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['access_token'] != null) {
        await _saveToken(response.data['access_token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Sync Firebase user with backend
  Future<Map<String, dynamic>> syncFirebaseUser({
    required String email,
    required String displayName,
    required String firebaseUid,
  }) async {
    try {
      final response = await _dio.post('/auth/sync', data: {
        'email': email,
        'display_name': displayName,
        'firebase_uid': firebaseUid,
      });

      if (response.data['access_token'] != null) {
        await _saveToken(response.data['access_token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete user account and all associated data
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _dio.delete('/auth/delete-account/$userId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tree endpoints
  Future<List<Map<String, dynamic>>> getTrees({
    double? latitude,
    double? longitude,
    double? radius,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'skip': skip,
      };

      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lon'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      final response = await _dio.get('/trees', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTree(String treeId) async {
    try {
      final response = await _dio.get('/trees/$treeId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createTree({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required double difficulty,
    required String treeType,
    required double height,
    List<String> imageUrls = const [],
    List<String> features = const [],
  }) async {
    try {
      final response = await _dio.post('/trees', data: {
        'name': name,
        'description': description,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'address': address,
        'difficulty': difficulty,
        'tree_type': treeType,
        'height': height,
        'image_urls': imageUrls,
        'features': features,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Review endpoints
  Future<Map<String, dynamic>> createReview({
    required String treeId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post('/reviews', data: {
        'tree_id': treeId,
        'rating': rating,
        'comment': comment,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getTreeReviews(String treeId) async {
    try {
      final response = await _dio.get('/reviews/tree/$treeId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyReviews() async {
    try {
      final response = await _dio.get('/reviews/user/my-reviews');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  bool get isAuthenticated => _authToken != null;

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Request failed with status: ${e.response!.statusCode}';
    }
    return 'Network error: ${e.message}';
  }
}