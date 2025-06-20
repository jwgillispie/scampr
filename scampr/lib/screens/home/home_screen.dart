import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/delete_account_dialog.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../models/tree_model.dart' as tree_model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapView(),
    const SearchView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to add tree screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add tree functionality coming soon!')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<tree_model.Tree> _trees = [];
  bool _isLoading = true;

  // Default location (San Francisco)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadTrees();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions first without requesting
      bool hasPermission = await _locationService.checkPermissions();
      if (hasPermission) {
        _currentPosition = await _locationService.getCurrentLocation();
      } else {
        debugPrint('Location permissions not granted, using default location');
      }
    } catch (e) {
      // Use default location if permission denied or location unavailable
      debugPrint('Location error: $e');
    }
  }

  Future<void> _loadTrees() async {
    try {
      final position = _currentPosition;
      List<Map<String, dynamic>> treesData;
      
      if (position != null) {
        // Load trees near user location
        treesData = await _apiService.getTrees(
          latitude: position.latitude,
          longitude: position.longitude,
          radius: 50.0, // 50km radius
          limit: 100,
        );
      } else {
        // Load trees without location filtering
        treesData = await _apiService.getTrees(limit: 100);
      }

      _trees = treesData.map((data) => tree_model.Tree.fromMap(data, data['id'] ?? '')).toList();
      _createMarkers();
    } catch (e) {
      debugPrint('Error loading trees: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load trees: $e')),
        );
      }
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    // Add user location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add tree markers
    for (final tree in _trees) {
      markers.add(
        Marker(
          markerId: MarkerId(tree.id),
          position: LatLng(tree.location.latitude, tree.location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: tree.name,
            snippet: '${tree.treeType} • ${tree.difficulty}/5 difficulty',
            onTap: () => _showTreeDetails(tree),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showTreeDetails(tree_model.Tree tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tree.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tree.treeType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('${tree.difficulty}/5'),
                  const SizedBox(width: 16),
                  const Icon(Icons.height, size: 20),
                  const SizedBox(width: 4),
                  Text('${tree.height}m'),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 4),
                  Text('${tree.climbCount} climbs'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                tree.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(tree.address, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
              if (tree.features.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Features:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tree.features
                      .map((feature) => Chip(
                            label: Text(feature),
                            backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _centerOnUserLocation() async {
    try {
      if (_currentPosition != null && _mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            15.0,
          ),
        );
      } else {
        // Try to request permission and get location
        bool hasPermission = await _locationService.requestPermissions();
        if (hasPermission) {
          Position? position = await _locationService.getCurrentLocation();
          if (position != null && _mapController != null) {
            _currentPosition = position;
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(position.latitude, position.longitude),
                15.0,
              ),
            );
            _createMarkers(); // Refresh markers to add user location
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission required to center map')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to get location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Trees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _centerOnUserLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : _defaultLocation,
                zoom: 13.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // We have our own button
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trees'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 16),
            Text(
              'Search Trees',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Search functionality coming soon!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: state is AuthLoading 
                    ? null 
                    : () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trees Climbed:', style: TextStyle(fontSize: 16)),
                        Text('0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trees Added:', style: TextStyle(fontSize: 16)),
                        Text('0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Account Management Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const DeleteAccountDialog(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
        },
      ),
    );
  }
}