import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/delete_account_dialog.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../services/nature_audio_service.dart';
import '../../models/tree_model.dart' as tree_model;
import '../../theme/nature_theme.dart';
import '../../widgets/nature_effects.dart';

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
    final audioService = Provider.of<NatureAudioService>(context, listen: false);
    
    return NatureGradientBackground(
      gradient: NatureTheme.forestGradient,
      child: LeafParticleEffect(
        particleCount: 15,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _pages[_currentIndex],
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: NatureTheme.forestGreen.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) async {
                    await audioService.playUISound('button_tap');
                    await audioService.playHapticFeedback(HapticFeedbackType.light);
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white.withValues(alpha: 0.6),
                  selectedFontSize: 14,
                  unselectedFontSize: 12,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: TreeGrowthAnimation(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: _currentIndex == 0
                              ? BoxDecoration(
                                  color: NatureTheme.springGreen.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: PulsatingIcon(
                            icon: Icons.map_outlined,
                            color: _currentIndex == 0 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                            size: 28,
                          ),
                        ),
                      ),
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: TreeGrowthAnimation(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: _currentIndex == 1
                              ? BoxDecoration(
                                  color: NatureTheme.springGreen.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: PulsatingIcon(
                            icon: Icons.search,
                            color: _currentIndex == 1 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                            size: 28,
                          ),
                        ),
                      ),
                      label: 'Discover',
                    ),
                    BottomNavigationBarItem(
                      icon: TreeGrowthAnimation(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: _currentIndex == 2
                              ? BoxDecoration(
                                  color: NatureTheme.springGreen.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: PulsatingIcon(
                            icon: Icons.person_outline,
                            color: _currentIndex == 2 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                            size: 28,
                          ),
                        ),
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _currentIndex == 0
              ? TreeGrowthAnimation(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          NatureTheme.springGreen,
                          NatureTheme.forestGreen,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NatureTheme.forestGreen.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        await audioService.playUISound('button_tap');
                        await audioService.playHapticFeedback(HapticFeedbackType.medium);
                        if (context.mounted) {
                          context.push('/add-tree');
                        }
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const PulsatingIcon(
                          icon: Icons.add_location_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      label: const Text(
                        'Add Tree',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
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
    final audioService = Provider.of<NatureAudioService>(context, listen: false);

    // Add user location marker with nature animation
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          builder: (context) => TreeGrowthAnimation(
            child: Container(
              decoration: BoxDecoration(
                color: NatureTheme.skyBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: NatureTheme.skyBlue.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const PulsatingIcon(
                icon: Icons.person_pin_circle,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      );
    }

    // Add tree markers with nature animations
    for (final tree in _trees) {
      markers.add(
        Marker(
          point: LatLng(tree.location.latitude, tree.location.longitude),
          builder: (context) => TreeGrowthAnimation(
            child: LeafFloatingEffect(
              intensity: 0.8,
              child: GestureDetector(
                onTap: () async {
                  await audioService.playUISound('tree_found');
                  await audioService.playHapticFeedback(HapticFeedbackType.medium);
                  _showTreeDetails(tree);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _getTreeGradient(tree.treeType),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NatureTheme.forestGreen.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: PulsatingIcon(
                    icon: _getTreeIcon(tree.treeType),
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  LinearGradient _getTreeGradient(String treeType) {
    switch (treeType.toLowerCase()) {
      case 'oak':
        return const LinearGradient(
          colors: [NatureTheme.chestnutBrown, NatureTheme.forestGreen],
        );
      case 'pine':
        return const LinearGradient(
          colors: [NatureTheme.deepForest, NatureTheme.forestGreen],
        );
      case 'maple':
        return const LinearGradient(
          colors: [NatureTheme.autumnOrange, NatureTheme.berryRed],
        );
      case 'birch':
        return const LinearGradient(
          colors: [NatureTheme.cloudWhite, NatureTheme.paleGreen],
        );
      default:
        return NatureTheme.leafGradient;
    }
  }

  IconData _getTreeIcon(String treeType) {
    switch (treeType.toLowerCase()) {
      case 'oak':
        return Icons.forest;
      case 'pine':
        return Icons.nature;
      case 'maple':
        return Icons.park;
      case 'birch':
        return Icons.grass;
      default:
        return Icons.eco;
    }
  }

  void _showTreeDetails(tree_model.Tree tree) {
    final audioService = Provider.of<NatureAudioService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => TreeGrowthAnimation(
        child: NatureCard(
          decoration: BoxDecoration(
            gradient: _getTreeGradient(tree.treeType),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header with animated tree icon
                  Row(
                    children: [
                      TreeGrowthAnimation(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: PulsatingIcon(
                            icon: _getTreeIcon(tree.treeType),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NatureTextAnimation(
                              text: tree.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tree.treeType,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TreeGrowthAnimation(
                        child: IconButton(
                          onPressed: () async {
                            await audioService.playUISound('button_tap');
                            await audioService.playHapticFeedback(HapticFeedbackType.light);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Row with animated icons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          iconColor: NatureTheme.sunYellow,
                          label: 'Difficulty',
                          value: '${tree.difficulty}/5',
                        ),
                        _buildStatItem(
                          icon: Icons.height,
                          iconColor: NatureTheme.forestGreen,
                          label: 'Height',
                          value: '${tree.height}m',
                        ),
                        _buildStatItem(
                          icon: Icons.people,
                          iconColor: NatureTheme.skyBlue,
                          label: 'Climbs',
                          value: '${tree.climbCount}',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description with nature styling
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      tree.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location with animated icon
                  Row(
                    children: [
                      const PulsatingIcon(
                        icon: Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tree.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (tree.features.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tree.features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        return TreeGrowthAnimation(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action Button
                  TreeGrowthAnimation(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await audioService.playUISound('climb_complete');
                        await audioService.playHapticFeedback(HapticFeedbackType.heavy);
                        Navigator.pop(context);
                      },
                      icon: const PulsatingIcon(
                        icon: Icons.hiking,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Start Climbing Adventure',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return TreeGrowthAnimation(
      child: Column(
        children: [
          PulsatingIcon(
            icon: icon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
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
    final audioService = Provider.of<NatureAudioService>(context, listen: false);
    
    return NatureGradientBackground(
      gradient: NatureTheme.leafGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Explore Nature',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          actions: [
            TreeGrowthAnimation(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const PulsatingIcon(
                    icon: Icons.my_location_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () async {
                    await audioService.playUISound('button_tap');
                    await audioService.playHapticFeedback(HapticFeedbackType.light);
                    _centerOnUserLocation();
                  },
                ),
              ),
            ),
            TreeGrowthAnimation(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    audioService.isEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () async {
                    await audioService.setEnabled(!audioService.isEnabled);
                    await audioService.playHapticFeedback(HapticFeedbackType.light);
                  },
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: TreeGrowthAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WaveLoadingIndicator(
                          color: Colors.white,
                          size: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Discovering nature...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : LeafFloatingEffect(
                intensity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        NatureTheme.skyBlue.withValues(alpha: 0.3),
                        NatureTheme.leafGreen.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                        onTap: (tapPosition, point) async {
                          await audioService.playUISound('pop');
                          await audioService.playHapticFeedback(HapticFeedbackType.light);
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
                ),
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
  final List<String> _selectedFeatures = [];

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
      // Get user location for innovative location-based scoring
      Position? userPosition;
      try {
        userPosition = await Geolocator.getCurrentPosition();
      } catch (e) {
        // Location access denied, continue without location scoring
      }

      // Use innovative search API endpoint
      final searchResults = await _apiService.searchTrees(
        query: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        latitude: userPosition?.latitude,
        longitude: userPosition?.longitude,
        radius: 50.0, // 50km radius
        treeType: _selectedTreeType != 'All' ? _selectedTreeType : null,
        difficultyMin: _selectedDifficulty > 0 ? _selectedDifficulty.toDouble() : null,
        difficultyMax: _selectedDifficulty > 0 ? _selectedDifficulty.toDouble() : null,
        preferredDifficulty: _selectedDifficulty > 0 ? _selectedDifficulty.toDouble() : null,
        features: _selectedFeatures.isNotEmpty ? _selectedFeatures : null,
        sortBy: 'relevance', // Prioritize attributes and location over name
        limit: 50,
      );
      
      final trees = searchResults.map((data) => tree_model.Tree.fromMap(data, data['id'] ?? '')).toList();

      setState(() {
        _searchResults = trees;
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
    final audioService = Provider.of<NatureAudioService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => TreeGrowthAnimation(
        child: NatureCard(
          decoration: BoxDecoration(
            gradient: _getTreeGradient(tree.treeType),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header with animated tree icon
                  Row(
                    children: [
                      TreeGrowthAnimation(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: PulsatingIcon(
                            icon: _getTreeIcon(tree.treeType),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NatureTextAnimation(
                              text: tree.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tree.treeType,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TreeGrowthAnimation(
                        child: IconButton(
                          onPressed: () async {
                            await audioService.playUISound('button_tap');
                            await audioService.playHapticFeedback(HapticFeedbackType.light);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Row with animated icons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.star,
                          iconColor: NatureTheme.sunYellow,
                          label: 'Difficulty',
                          value: '${tree.difficulty}/5',
                        ),
                        _buildStatItem(
                          icon: Icons.height,
                          iconColor: NatureTheme.forestGreen,
                          label: 'Height',
                          value: '${tree.height}m',
                        ),
                        _buildStatItem(
                          icon: Icons.people,
                          iconColor: NatureTheme.skyBlue,
                          label: 'Climbs',
                          value: '${tree.climbCount}',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description with nature styling
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      tree.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location with animated icon
                  Row(
                    children: [
                      const PulsatingIcon(
                        icon: Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tree.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (tree.features.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tree.features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        return TreeGrowthAnimation(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action Button
                  TreeGrowthAnimation(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await audioService.playUISound('climb_complete');
                        await audioService.playHapticFeedback(HapticFeedbackType.heavy);
                        Navigator.pop(context);
                      },
                      icon: const PulsatingIcon(
                        icon: Icons.hiking,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Start Climbing Adventure',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return TreeGrowthAnimation(
      child: Column(
        children: [
          PulsatingIcon(
            icon: icon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<NatureAudioService>(context, listen: false);
    
    return NatureGradientBackground(
      gradient: NatureTheme.sunriseGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Discover Trees',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          actions: [
            if (_hasSearched)
              TreeGrowthAnimation(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await audioService.playUISound('swipe');
                      await audioService.playHapticFeedback(HapticFeedbackType.light);
                      _clearSearch();
                    },
                    icon: const PulsatingIcon(
                      icon: Icons.clear_all,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: LeafParticleEffect(
          particleCount: 12,
          particleColor: NatureTheme.autumnOrange,
          child: Column(
            children: [
              // Search input and filters
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search bar with modern styling
                      TreeGrowthAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.95),
                                Colors.white.withValues(alpha: 0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: NatureTheme.forestGreen.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 20),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: NatureTheme.deepForest,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search trees by name, type, or description...',
                              hintStyle: TextStyle(
                                color: NatureTheme.deepForest.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(12),
                                child: const PulsatingIcon(
                                  icon: Icons.search_outlined,
                                  color: NatureTheme.forestGreen,
                                  size: 24,
                                ),
                              ),
                              suffixIcon: _isSearching
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: WaveLoadingIndicator(
                                          color: NatureTheme.forestGreen,
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            NatureTheme.springGreen,
                                            NatureTheme.forestGreen,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: NatureTheme.forestGreen.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          await audioService.playUISound('button_tap');
                                          await audioService.playHapticFeedback(HapticFeedbackType.light);
                                          _performSearch();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                            onSubmitted: (_) async {
                              await audioService.playUISound('button_tap');
                              await audioService.playHapticFeedback(HapticFeedbackType.light);
                              _performSearch();
                            },
                          ),
                        ),
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
        ),
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
      return Center(
        child: TreeGrowthAnimation(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WaveLoadingIndicator(
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(height: 20),
                Text(
                  'Searching for trees...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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
        return TreeGrowthAnimation(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _getTreeGradient(tree.treeType).colors.first.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showTreeDetails(tree),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: _getTreeGradient(tree.treeType),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getTreeGradient(tree.treeType).colors.first.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            tree.difficulty.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tree.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: NatureTheme.deepForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tree.treeType,
                              style: TextStyle(
                                fontSize: 14,
                                color: NatureTheme.forestGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tree.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: NatureTheme.deepForest.withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                            ),
                            if (tree.features.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: tree.features.take(3).map((feature) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: NatureTheme.springGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: NatureTheme.springGreen.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: NatureTheme.forestGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NatureTheme.leafGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.height,
                              size: 20,
                              color: NatureTheme.forestGreen,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tree.height}m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: NatureTheme.forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getTreeGradient(String treeType) {
    switch (treeType.toLowerCase()) {
      case 'oak':
        return const LinearGradient(
          colors: [NatureTheme.chestnutBrown, NatureTheme.forestGreen],
        );
      case 'pine':
        return const LinearGradient(
          colors: [NatureTheme.deepForest, NatureTheme.forestGreen],
        );
      case 'maple':
        return const LinearGradient(
          colors: [NatureTheme.autumnOrange, NatureTheme.berryRed],
        );
      case 'birch':
        return const LinearGradient(
          colors: [NatureTheme.cloudWhite, NatureTheme.paleGreen],
        );
      default:
        return NatureTheme.leafGradient;
    }
  }

  IconData _getTreeIcon(String treeType) {
    switch (treeType.toLowerCase()) {
      case 'oak':
        return Icons.forest;
      case 'pine':
        return Icons.nature;
      case 'maple':
        return Icons.park;
      case 'birch':
        return Icons.grass;
      default:
        return Icons.eco;
    }
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