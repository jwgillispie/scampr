import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (e) {
      throw Exception('Failed to pick image from gallery: ${e.toString()}');
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    } catch (e) {
      throw Exception('Failed to pick image from camera: ${e.toString()}');
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage(imageQuality: 80);
    } catch (e) {
      throw Exception('Failed to pick multiple images: ${e.toString()}');
    }
  }

  Future<String> uploadTreeImage(String treeId, XFile imageFile, int index) async {
    try {
      // For now, return a placeholder URL
      // TODO: Implement backend file upload endpoint
      return 'https://placeholder-image-url.com/tree-$treeId-$index.jpg';
    } catch (e) {
      throw Exception('Failed to upload tree image: ${e.toString()}');
    }
  }

  Future<List<String>> uploadTreeImages(String treeId, List<XFile> imageFiles) async {
    try {
      List<String> imageUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        String imageUrl = await uploadTreeImage(treeId, imageFiles[i], i);
        imageUrls.add(imageUrl);
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload tree images: ${e.toString()}');
    }
  }

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      // For now, return a placeholder URL
      // TODO: Implement backend file upload endpoint
      return 'https://placeholder-image-url.com/profile-$userId.jpg';
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      // TODO: Implement backend file deletion endpoint
      // For now, this is a no-op
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  Future<void> deleteTreeImages(String treeId) async {
    try {
      // TODO: Implement backend file deletion endpoint
      // For now, this is a no-op
    } catch (e) {
      throw Exception('Failed to delete tree images: ${e.toString()}');
    }
  }

  // Helper method for future backend file upload implementation
  Future<String> _uploadToBackend(XFile file, String path) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
        'path': path,
      });

      final response = await _dio.post(
        'http://localhost:8000/api/v1/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload to backend: ${e.toString()}');
    }
  }
}