
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

class Tree {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String address;
  final String userId;
  final String userName;
  final List<String> imageUrls;
  final double difficulty;
  final String treeType;
  final double height;
  final List<String> features;
  final DateTime createdAt;
  final int climbCount;
  final double averageRating;

  Tree({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.userId,
    required this.userName,
    required this.imageUrls,
    required this.difficulty,
    required this.treeType,
    required this.height,
    required this.features,
    required this.createdAt,
    this.climbCount = 0,
    this.averageRating = 0.0,
  });

  factory Tree.fromMap(Map<String, dynamic> map, String documentId) {
    return Tree(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] != null ? LatLng(map['location']['latitude'], map['location']['longitude']) : const LatLng(0, 0),
      address: map['address'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      difficulty: (map['difficulty'] ?? 0.0).toDouble(),
      treeType: map['treeType'] ?? '',
      height: (map['height'] ?? 0.0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      climbCount: map['climbCount'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': {'latitude': location.latitude, 'longitude': location.longitude},
      'address': address,
      'userId': userId,
      'userName': userName,
      'imageUrls': imageUrls,
      'difficulty': difficulty,
      'treeType': treeType,
      'height': height,
      'features': features,
      'createdAt': createdAt.toIso8601String(),
      'climbCount': climbCount,
      'averageRating': averageRating,
    };
  }

  Tree copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? location,
    String? address,
    String? userId,
    String? userName,
    List<String>? imageUrls,
    double? difficulty,
    String? treeType,
    double? height,
    List<String>? features,
    DateTime? createdAt,
    int? climbCount,
    double? averageRating,
  }) {
    return Tree(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      imageUrls: imageUrls ?? this.imageUrls,
      difficulty: difficulty ?? this.difficulty,
      treeType: treeType ?? this.treeType,
      height: height ?? this.height,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      climbCount: climbCount ?? this.climbCount,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}