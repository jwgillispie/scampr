// Removed Firebase dependencies

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final List<String> climbedTrees;
  final List<String> addedTrees;
  final DateTime joinedDate;
  final int totalClimbs;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.climbedTrees,
    required this.addedTrees,
    required this.joinedDate,
    this.totalClimbs = 0,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      climbedTrees: List<String>.from(map['climbedTrees'] ?? []),
      addedTrees: List<String>.from(map['addedTrees'] ?? []),
      joinedDate: DateTime.parse(map['joinedDate'] ?? DateTime.now().toIso8601String()),
      totalClimbs: map['totalClimbs'] ?? 0,
    );
  }

  factory AppUser.fromApiMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      profileImageUrl: map['profile_image_url'],
      climbedTrees: [], // Backend doesn't return this field in auth response
      addedTrees: [], // Backend doesn't return this field in auth response  
      joinedDate: DateTime.now(), // Backend doesn't return this field in auth response
      totalClimbs: map['total_climbs'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'climbedTrees': climbedTrees,
      'addedTrees': addedTrees,
      'joinedDate': joinedDate.toIso8601String(),
      'totalClimbs': totalClimbs,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    List<String>? climbedTrees,
    List<String>? addedTrees,
    DateTime? joinedDate,
    int? totalClimbs,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      climbedTrees: climbedTrees ?? this.climbedTrees,
      addedTrees: addedTrees ?? this.addedTrees,
      joinedDate: joinedDate ?? this.joinedDate,
      totalClimbs: totalClimbs ?? this.totalClimbs,
    );
  }
}