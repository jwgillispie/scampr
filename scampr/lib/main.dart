import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';

void main() {
  runApp(const ScamprApp());
}

class ScamprApp extends StatelessWidget {
  const ScamprApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scampr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest green
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF8D6E63), // Brown
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
      home: const FirebaseInitWrapper(),
    );
  }
}

class FirebaseInitWrapper extends StatefulWidget {
  const FirebaseInitWrapper({super.key});

  @override
  State<FirebaseInitWrapper> createState() => _FirebaseInitWrapperState();
}

class _FirebaseInitWrapperState extends State<FirebaseInitWrapper> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        setState(() {
          _initialized = true;
        });
        return;
      } catch (e) {
        // Firebase not yet initialized, proceeding with initialization
      }
      
      // Try default initialization first
      await Firebase.initializeApp();
      
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Fall back to explicit options
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyA6_-hJikarPqY_D6vI6G97cSjx0TSZc50",
            appId: "1:170870941614:ios:a07d00733c74b1e1008a3f",
            messagingSenderId: "170870941614",
            projectId: "scampr-trees",
            storageBucket: "scampr-trees.firebasestorage.app",
          ),
        );
        setState(() {
          _initialized = true;
        });
      } catch (fallbackError) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Scaffold(
        body: Center(
          child: Text('Error initializing Firebase'),
        ),
      );
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const AppWithProviders();
  }
}

class AppWithProviders extends StatelessWidget {
  const AppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core API service - no dependencies
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        
        // Database service - depends on ApiService
        Provider<DatabaseService>(
          create: (context) => DatabaseService(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
        
        // Location service - no dependencies
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        
        // Storage service - no dependencies
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        
        // Auth service - depends on ApiService
        Provider<AuthService>(
          create: (context) => AuthService(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: const AppWithBloc(),
    );
  }
}

class AppWithBloc extends StatelessWidget {
  const AppWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authService: Provider.of<AuthService>(context, listen: false),
      )..add(AuthStarted()),
      child: const ScamprAppWithRouter(),
    );
  }
}

class ScamprAppWithRouter extends StatelessWidget {
  const ScamprAppWithRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ),
      routes: [
        GoRoute(
          path: '/',
          name: 'auth-check',
          builder: (context, state) => const AuthWrapper(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToSignup = state.matchedLocation == '/signup';

        // If not authenticated and not going to auth screens, redirect to login
        if (!isAuthenticated && !isGoingToLogin && !isGoingToSignup) {
          return '/login';
        }

        // If authenticated and going to auth screens, redirect to home
        if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
          return '/home';
        }

        // If authenticated and not specifically going anywhere, go to home
        if (isAuthenticated && state.matchedLocation == '/') {
          return '/home';
        }

        // No redirect needed
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Scampr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest green
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF8D6E63), // Brown
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          // User is authenticated, redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is AuthError) {
          // Show error and redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // User is not authenticated, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}