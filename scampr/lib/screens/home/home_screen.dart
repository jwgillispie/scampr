import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
                context.push('/add-tree');
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
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  
  Position? _currentPosition;
  List<Marker> _markers = [];
  List<tree_model.Tree> _trees = [];
  bool _isLoading = true;

  // Default location (San Francisco)
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
      // Check permissions first
      bool hasPermission = await _locationService.checkPermissions();
      if (!hasPermission) {
        // Request permissions if not granted
        hasPermission = await _locationService.requestPermissions();
      }
      
      if (hasPermission) {
        _currentPosition = await _locationService.getCurrentLocation();
        debugPrint('Got user location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
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
    final markers = <Marker>[];

    // Add user location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          builder: (context) => const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Add tree markers
    for (final tree in _trees) {
      markers.add(
        Marker(
          point: LatLng(tree.location.latitude, tree.location.longitude),
          builder: (context) => GestureDetector(
            onTap: () => _showTreeDetails(tree),
            child: const Icon(
              Icons.park,
              color: Colors.green,
              size: 40,
            ),
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
      if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        );
      } else {
        // Try to request permission and get location
        bool hasPermission = await _locationService.requestPermissions();
        if (hasPermission) {
          Position? position = await _locationService.getCurrentLocation();
          if (position != null) {
            _currentPosition = position;
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              15.0,
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
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : _defaultLocation,
                  zoom: 13.0,
                  onMapReady: () {
                    debugPrint('FlutterMap created successfully');
                    debugPrint('Initial camera position: ${_currentPosition != null ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}' : 'Default SF location'}');
                    debugPrint('Number of markers: ${_markers.length}');
                    
                    // Center map on user location if available
                    if (_currentPosition != null) {
                      _mapController.move(
                        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        15.0,
                      );
                    }
                  },
                  onTap: (tapPosition, point) {
                    debugPrint('Map tapped at: ${point.latitude}, ${point.longitude}');
                  },
                  onPositionChanged: (position, hasGesture) {
                    debugPrint('Camera moved to: ${position.center!.latitude}, ${position.center!.longitude}');
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.scampr',
                  ),
                  MarkerLayer(
                    markers: _markers,
                  ),
                ],
              ),
            ),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  final _apiService = ApiService();
  
  List<tree_model.Tree> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _selectedTreeType = 'All';
  int _selectedDifficulty = 0; // 0 means all difficulties
  List<String> _selectedFeatures = [];

  final List<String> _treeTypes = [
    'All',
    'Oak',
    'Pine',
    'Maple',
    'Cedar',
    'Birch',
    'Willow',
    'Elm',
    'Hickory',
    'Magnolia',
    'Dogwood'
  ];

  final List<String> _availableFeatures = [
    'Easy access',
    'Good branches',
    'Great view',
    'Beginner friendly',
    'Challenging climb',
    'Scenic location',
    'Wildlife nearby',
    'Photo spot',
    'Shaded area',
    'Open area'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty && 
        _selectedTreeType == 'All' && 
        _selectedDifficulty == 0 && 
        _selectedFeatures.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // For now, get all trees and filter client-side
      // TODO: Implement proper search API endpoint
      final allTrees = await _apiService.getTrees(limit: 100);
      final trees = allTrees.map((data) => tree_model.Tree.fromMap(data, data['id'] ?? '')).toList();
      
      // Filter results
      final filteredTrees = trees.where((tree) {
        // Text search
        if (_searchController.text.trim().isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!tree.name.toLowerCase().contains(query) &&
              !tree.description.toLowerCase().contains(query) &&
              !tree.treeType.toLowerCase().contains(query)) {
            return false;
          }
        }
        
        // Tree type filter
        if (_selectedTreeType != 'All' && tree.treeType != _selectedTreeType) {
          return false;
        }
        
        // Difficulty filter
        if (_selectedDifficulty > 0 && tree.difficulty != _selectedDifficulty) {
          return false;
        }
        
        // Features filter
        if (_selectedFeatures.isNotEmpty) {
          bool hasSelectedFeature = false;
          for (String feature in _selectedFeatures) {
            if (tree.features.contains(feature)) {
              hasSelectedFeature = true;
              break;
            }
          }
          if (!hasSelectedFeature) {
            return false;
          }
        }
        
        return true;
      }).toList();

      setState(() {
        _searchResults = filteredTrees;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedTreeType = 'All';
      _selectedDifficulty = 0;
      _selectedFeatures.clear();
      _searchResults.clear();
      _hasSearched = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trees'),
        actions: [
          if (_hasSearched)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search input and filters
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search trees by name, type, or description...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              onPressed: _performSearch,
                              icon: const Icon(Icons.arrow_forward),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filters
                  ExpansionTile(
                    title: const Text('Filters'),
                    children: [
                      // Tree type filter
                      ListTile(
                        title: const Text('Tree Type'),
                        subtitle: DropdownButton<String>(
                          value: _selectedTreeType,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedTreeType = value!;
                            });
                          },
                          items: _treeTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )).toList(),
                        ),
                      ),
                      
                      // Difficulty filter
                      ListTile(
                        title: const Text('Difficulty'),
                        subtitle: DropdownButton<int>(
                          value: _selectedDifficulty,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                          },
                          items: [
                            const DropdownMenuItem(value: 0, child: Text('All')),
                            ...List.generate(5, (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text('${index + 1}/5'),
                            )),
                          ],
                        ),
                      ),
                      
                      // Features filter
                      ListTile(
                        title: const Text('Features'),
                        subtitle: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _availableFeatures.map((feature) {
                                final isSelected = _selectedFeatures.contains(feature);
                                return FilterChip(
                                  label: Text(
                                    feature,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedFeatures.add(feature);
                                      } else {
                                        _selectedFeatures.remove(feature);
                                      }
                                    });
                                  },
                                  selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      
                      // Search button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSearching ? null : _performSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Search Trees'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: Color(0xFF2E7D32),
              ),
              SizedBox(height: 16),
              Text(
                'Search for Trees',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Use the search bar and filters above to find trees',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No Trees Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Try adjusting your search criteria',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final tree = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                tree.difficulty.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              tree.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tree.treeType),
                Text(
                  tree.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                if (tree.features.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: tree.features.take(3).map((feature) => Chip(
                      label: Text(
                        feature,
                        style: const TextStyle(fontSize: 10),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    )).toList(),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.height, size: 16),
                Text('${tree.height}m'),
              ],
            ),
            onTap: () => _showTreeDetails(tree),
          ),
        );
      },
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