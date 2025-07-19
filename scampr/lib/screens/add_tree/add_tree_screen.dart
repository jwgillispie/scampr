import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import 'dart:io';

class AddTreeScreen extends StatefulWidget {
  const AddTreeScreen({super.key});

  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _heightController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  int _difficulty = 3;
  List<String> _selectedFeatures = [];
  List<XFile> _selectedImages = [];
  Position? _selectedLocation;
  bool _isLoading = false;
  bool _useCurrentLocation = true;

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

  final List<String> _commonTreeTypes = [
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _heightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool hasPermission = await _locationService.checkPermissions();
      if (!hasPermission) {
        hasPermission = await _locationService.requestPermissions();
      }
      
      if (hasPermission) {
        Position? position = await _locationService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _selectedLocation = position;
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // Limit to 5 images
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.take(5).toList();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleFeature(String feature) {
    setState(() {
      if (_selectedFeatures.contains(feature)) {
        _selectedFeatures.remove(feature);
      } else {
        _selectedFeatures.add(feature);
      }
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location for the tree')),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _submitTree() async {
    if (!_validateForm()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create tree data
      final treeData = {
        'name': _nameController.text.trim(),
        'treeType': _typeController.text.trim(),
        'difficulty': _difficulty,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'features': _selectedFeatures,
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
      };
      
      // For now, create tree without images since backend doesn't support image upload yet
      // TODO: Add image upload support to backend
      await _apiService.createTree(
        name: treeData['name'] as String,
        description: treeData['description'] as String,
        latitude: (treeData['location'] as Map<String, dynamic>)['latitude'] as double,
        longitude: (treeData['location'] as Map<String, dynamic>)['longitude'] as double,
        address: 'Location coordinates', // Placeholder for address
        difficulty: (treeData['difficulty'] as int).toDouble(),
        treeType: treeData['treeType'] as String,
        height: treeData['height'] as double,
        features: List<String>.from(treeData['features'] as List),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tree added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding tree: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Tree'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submitTree,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('SAVE'),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tree Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tree Name *',
                hintText: 'Give this tree a memorable name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a tree name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tree Type
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Tree Type *',
                hintText: 'e.g., Oak, Pine, Maple',
                border: const OutlineInputBorder(),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    _typeController.text = value;
                  },
                  itemBuilder: (context) => _commonTreeTypes
                      .map((type) => PopupMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the tree type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Difficulty
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficulty Level: $_difficulty/5',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _difficulty.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _difficulty.toString(),
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value.round();
                        });
                      },
                    ),
                    const Text(
                      '1 = Very Easy, 3 = Moderate, 5 = Very Difficult',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Height
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (meters)',
                hintText: 'Approximate height of the tree',
                border: OutlineInputBorder(),
                suffixText: 'm',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Please enter a valid height';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the tree, climbing experience, or any tips',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please add a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableFeatures.map((feature) {
                        final isSelected = _selectedFeatures.contains(feature);
                        return FilterChip(
                          label: Text(feature),
                          selected: isSelected,
                          onSelected: (_) => _toggleFeature(feature),
                          selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tree Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedLocation != null)
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}\n'
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      )
                    else
                      const Text('No location selected'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use Current Location'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final initialLocation = _selectedLocation != null
                                  ? LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
                                  : null;
                              
                              final result = await context.pushNamed(
                                'map-picker',
                                extra: {'initialLocation': initialLocation},
                              );
                              
                              if (result is LatLng) {
                                setState(() {
                                  _selectedLocation = Position(
                                    latitude: result.latitude,
                                    longitude: result.longitude,
                                    timestamp: DateTime.now(),
                                    accuracy: 0,
                                    altitude: 0,
                                    altitudeAccuracy: 0,
                                    heading: 0,
                                    headingAccuracy: 0,
                                    speed: 0,
                                    speedAccuracy: 0,
                                  );
                                });
                              }
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Pick on Map'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Photos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos (${_selectedImages.length}/5)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _selectedImages.length < 5 ? _pickImages : null,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Photos'),
                        ),
                      ],
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('ADD TREE'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}