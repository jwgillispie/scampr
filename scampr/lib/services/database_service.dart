import '../models/tree_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import 'api_service.dart';

class DatabaseService {
  final ApiService _apiService;

  DatabaseService({required ApiService apiService}) : _apiService = apiService;

  // User operations
  Future<void> createUser(AppUser user) async {
    // User creation is handled by the auth endpoints in ApiService
    // This method can be removed or kept as a placeholder
  }

  Future<AppUser?> getUserData(String userId) async {
    // For now, return null as user data comes from JWT token
    // Could be extended to fetch additional user profile data
    return null;
  }

  Future<void> updateUserDisplayName(String userId, String displayName) async {
    // Would need to add user profile update endpoint to backend
    throw UnimplementedError('User profile updates not implemented yet');
  }

  // Tree operations
  Future<String> createTree(Tree tree) async {
    try {
      final response = await _apiService.createTree(
        name: tree.name,
        description: tree.description,
        latitude: tree.location.latitude,
        longitude: tree.location.longitude,
        address: tree.address,
        difficulty: tree.difficulty,
        treeType: tree.treeType,
        height: tree.height,
        imageUrls: tree.imageUrls,
        features: tree.features,
      );
      return response['id'];
    } catch (e) {
      throw Exception('Failed to create tree: ${e.toString()}');
    }
  }

  Future<List<Tree>> getNearbyTrees(LatLng center, double radiusKm) async {
    try {
      final treesData = await _apiService.getTrees(
        latitude: center.latitude,
        longitude: center.longitude,
        radius: radiusKm,
      );
      
      return treesData.map((treeData) => Tree.fromMap(treeData, treeData['id'])).toList();
    } catch (e) {
      throw Exception('Failed to get nearby trees: ${e.toString()}');
    }
  }

  Future<Tree?> getTree(String treeId) async {
    try {
      final treeData = await _apiService.getTree(treeId);
      return Tree.fromMap(treeData, treeData['id']);
    } catch (e) {
      throw Exception('Failed to get tree: ${e.toString()}');
    }
  }

  Future<List<Tree>> searchTrees(String query) async {
    try {
      // For now, get all trees and filter client-side
      // Could be optimized with a backend search endpoint
      final treesData = await _apiService.getTrees();
      final trees = treesData.map((treeData) => Tree.fromMap(treeData, treeData['id'])).toList();
      
      return trees.where((tree) => 
        tree.name.toLowerCase().contains(query.toLowerCase()) ||
        tree.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search trees: ${e.toString()}');
    }
  }

  Future<void> markTreeAsClimbed(String userId, String treeId) async {
    // This would need to be implemented as a backend endpoint
    // For now, we'll skip this functionality
    throw UnimplementedError('Mark tree as climbed not implemented yet');
  }

  // Review operations
  Future<String> createReview(Review review) async {
    try {
      final response = await _apiService.createReview(
        treeId: review.treeId,
        rating: review.rating,
        comment: review.comment,
      );
      return response['id'];
    } catch (e) {
      throw Exception('Failed to create review: ${e.toString()}');
    }
  }

  Future<List<Review>> getTreeReviews(String treeId) async {
    try {
      final reviewsData = await _apiService.getTreeReviews(treeId);
      return reviewsData.map((reviewData) => Review.fromMap(reviewData, reviewData['id'])).toList();
    } catch (e) {
      throw Exception('Failed to get tree reviews: ${e.toString()}');
    }
  }

  Future<List<Review>> getUserReviews() async {
    try {
      final reviewsData = await _apiService.getMyReviews();
      return reviewsData.map((reviewData) => Review.fromMap(reviewData, reviewData['id'])).toList();
    } catch (e) {
      throw Exception('Failed to get user reviews: ${e.toString()}');
    }
  }
}