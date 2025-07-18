class AppConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'http://localhost:8000';
  static const String _prodBaseUrl = 'https://scampr-backend.onrender.com';
  
  // Get base URL based on environment
  static String get baseUrl {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return environment == 'production' ? _prodBaseUrl : _devBaseUrl;
  }
  
  // API endpoints
  static String get apiUrl => '$baseUrl/api';
  static String get authUrl => '$baseUrl/auth';
  static String get treesUrl => '$baseUrl/api/trees';
  static String get usersUrl => '$baseUrl/api/users';
  static String get reviewsUrl => '$baseUrl/api/reviews';
  
  // App configuration
  static const String appName = 'Scampr';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Tree Climbing Adventure';
  
  // Feature flags
  static const bool enableAudio = true;
  static const bool enableNotifications = true;
  static const bool enableLocationServices = true;
  
  // API timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Cache settings
  static const int cacheMaxAge = 300; // 5 minutes
  static const int imageCacheMaxAge = 3600; // 1 hour
  
  // Map settings
  static const double defaultZoom = 13.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 8.0;
  
  // Search settings
  static const int searchRadius = 50; // km
  static const int maxSearchResults = 50;
  
  // Debug settings
  static const bool enableDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool enableLogging = bool.fromEnvironment('LOGGING', defaultValue: true);
}