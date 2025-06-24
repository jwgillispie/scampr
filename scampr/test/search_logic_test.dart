import 'package:flutter_test/flutter_test.dart';
import 'package:scampr/models/tree_model.dart' as tree_model;

void main() {
  group('Tree Search Logic Tests', () {
    late List<tree_model.Tree> sampleTrees;

    setUp(() {
      // Create sample trees for testing
      sampleTrees = [
        tree_model.Tree(
          id: '1',
          name: 'Giant Oak Tree',
          description: 'Beautiful massive oak perfect for climbing',
          location: const tree_model.LatLng(37.7749, -122.4194),
          address: 'Golden Gate Park, San Francisco',
          userId: 'user1',
          userName: 'TreeClimber1',
          imageUrls: [],
          difficulty: 3.0,
          treeType: 'Oak',
          height: 25.0,
          features: ['Easy access', 'Good branches', 'Scenic location'],
          createdAt: DateTime.now(),
          climbCount: 15,
          averageRating: 4.5,
        ),
        tree_model.Tree(
          id: '2',
          name: 'Climbing Pine',
          description: 'Challenging pine tree for experienced climbers',
          location: const tree_model.LatLng(37.7849, -122.4094),
          address: 'Mission District, San Francisco',
          userId: 'user2',
          userName: 'TreeClimber2',
          imageUrls: [],
          difficulty: 5.0,
          treeType: 'Pine',
          height: 30.0,
          features: ['Challenging climb', 'Great view', 'Photo spot'],
          createdAt: DateTime.now(),
          climbCount: 8,
          averageRating: 4.8,
        ),
        tree_model.Tree(
          id: '3',
          name: 'Beginner Maple',
          description: 'Perfect maple tree for beginners to learn climbing',
          location: const tree_model.LatLng(37.7649, -122.4294),
          address: 'Central Park, San Francisco',
          userId: 'user3',
          userName: 'TreeClimber3',
          imageUrls: [],
          difficulty: 1.0,
          treeType: 'Maple',
          height: 15.0,
          features: ['Beginner friendly', 'Easy access', 'Shaded area'],
          createdAt: DateTime.now(),
          climbCount: 25,
          averageRating: 4.2,
        ),
        tree_model.Tree(
          id: '4',
          name: 'Ancient Cedar',
          description: 'Old growth cedar with amazing branches',
          location: const tree_model.LatLng(37.7949, -122.3894),
          address: 'Presidio, San Francisco',
          userId: 'user4',
          userName: 'TreeClimber4',
          imageUrls: [],
          difficulty: 4.0,
          treeType: 'Cedar',
          height: 40.0,
          features: ['Good branches', 'Wildlife nearby', 'Challenging climb'],
          createdAt: DateTime.now(),
          climbCount: 12,
          averageRating: 4.7,
        ),
      ];
    });

    test('Text search should work correctly', () {
      // Test name search
      var results = filterTrees(sampleTrees, query: 'oak');
      expect(results.length, 1);
      expect(results.first.name, 'Giant Oak Tree');

      // Test description search
      results = filterTrees(sampleTrees, query: 'beginner');
      expect(results.length, 1);
      expect(results.first.name, 'Beginner Maple');

      // Test tree type search
      results = filterTrees(sampleTrees, query: 'pine');
      expect(results.length, 1);
      expect(results.first.name, 'Climbing Pine');

      // Test case insensitive search
      results = filterTrees(sampleTrees, query: 'CLIMBING');
      expect(results.length, 3); // "Climbing Pine", "perfect for climbing", and "learn climbing"

      // Test partial word search
      results = filterTrees(sampleTrees, query: 'anc');
      expect(results.length, 1);
      expect(results.first.name, 'Ancient Cedar');
    });

    test('Tree type filter should work correctly', () {
      var results = filterTrees(sampleTrees, treeType: 'Oak');
      expect(results.length, 1);
      expect(results.first.treeType, 'Oak');

      results = filterTrees(sampleTrees, treeType: 'Pine');
      expect(results.length, 1);
      expect(results.first.treeType, 'Pine');

      results = filterTrees(sampleTrees, treeType: 'All');
      expect(results.length, 4);
    });

    test('Difficulty filter should work correctly', () {
      var results = filterTrees(sampleTrees, difficulty: 1);
      expect(results.length, 1);
      expect(results.first.difficulty, 1.0);

      results = filterTrees(sampleTrees, difficulty: 3);
      expect(results.length, 1);
      expect(results.first.difficulty, 3.0);

      results = filterTrees(sampleTrees, difficulty: 5);
      expect(results.length, 1);
      expect(results.first.difficulty, 5.0);

      // Test difficulty 0 (all difficulties)
      results = filterTrees(sampleTrees, difficulty: 0);
      expect(results.length, 4);
    });

    test('Features filter should work correctly', () {
      var results = filterTrees(sampleTrees, features: ['Easy access']);
      expect(results.length, 2); // Oak and Maple have "Easy access"

      results = filterTrees(sampleTrees, features: ['Challenging climb']);
      expect(results.length, 2); // Pine and Cedar have "Challenging climb"

      results = filterTrees(sampleTrees, features: ['Beginner friendly']);
      expect(results.length, 1);
      expect(results.first.name, 'Beginner Maple');

      // Test multiple features (OR logic - should find trees with ANY of the features)
      results = filterTrees(sampleTrees, features: ['Photo spot', 'Wildlife nearby']);
      expect(results.length, 2); // Pine has "Photo spot", Cedar has "Wildlife nearby"
    });

    test('Combined filters should work correctly', () {
      // Search for Oak trees with difficulty 3
      var results = filterTrees(sampleTrees, treeType: 'Oak', difficulty: 3);
      expect(results.length, 1);
      expect(results.first.name, 'Giant Oak Tree');

      // Search for trees with "Easy access" feature and difficulty 1
      results = filterTrees(sampleTrees, features: ['Easy access'], difficulty: 1);
      expect(results.length, 1);
      expect(results.first.name, 'Beginner Maple');

      // Search for "climbing" in description with Pine type
      results = filterTrees(sampleTrees, query: 'climbing', treeType: 'Pine');
      expect(results.length, 1);
      expect(results.first.name, 'Climbing Pine');

      // Search that should return no results
      results = filterTrees(sampleTrees, treeType: 'Oak', difficulty: 5);
      expect(results.length, 0);
    });

    test('Empty search should return all trees', () {
      var results = filterTrees(sampleTrees);
      expect(results.length, 4);
    });

    test('Search with no matches should return empty list', () {
      var results = filterTrees(sampleTrees, query: 'nonexistent');
      expect(results.length, 0);

      results = filterTrees(sampleTrees, treeType: 'Nonexistent');
      expect(results.length, 0);

      results = filterTrees(sampleTrees, features: ['Nonexistent feature']);
      expect(results.length, 0);
    });

    test('Edge cases should be handled correctly', () {
      // Empty query string
      var results = filterTrees(sampleTrees, query: '');
      expect(results.length, 4);

      // Query with only whitespace
      results = filterTrees(sampleTrees, query: '   ');
      expect(results.length, 4);

      // Special characters in query
      results = filterTrees(sampleTrees, query: 'tree,');
      expect(results.length, 0); // No tree has comma in name/description

      // Very long query
      results = filterTrees(sampleTrees, query: 'this is a very long query that should not match anything');
      expect(results.length, 0);
    });
  });
}

// Helper function that mimics the actual search logic from the app
List<tree_model.Tree> filterTrees(
  List<tree_model.Tree> trees, {
  String? query,
  String treeType = 'All',
  int difficulty = 0,
  List<String> features = const [],
}) {
  return trees.where((tree) {
    // Text search
    if (query != null && query.trim().isNotEmpty) {
      final searchQuery = query.toLowerCase();
      if (!tree.name.toLowerCase().contains(searchQuery) &&
          !tree.description.toLowerCase().contains(searchQuery) &&
          !tree.treeType.toLowerCase().contains(searchQuery)) {
        return false;
      }
    }
    
    // Tree type filter
    if (treeType != 'All' && tree.treeType != treeType) {
      return false;
    }
    
    // Difficulty filter
    if (difficulty > 0 && tree.difficulty != difficulty) {
      return false;
    }
    
    // Features filter
    if (features.isNotEmpty) {
      bool hasSelectedFeature = false;
      for (String feature in features) {
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
}