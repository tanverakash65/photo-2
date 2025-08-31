import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final commonCloudinaryStorageRepositoryProvider = Provider(
      (ref) => CommonCloudinaryStorageRepository(),
);

class CommonCloudinaryStorageRepository {
  static const String cloudName = 'dc6j57sq0'; // Your cloud name
  static const String uploadPreset = 'chat_files'; // Create this preset in Cloudinary

  Future<String> storeFileToCloudinary(String ref, File file) async {
    try {
      print('🌤️ Uploading file to Cloudinary: $ref');

      // Determine resource type based on file extension
      String resourceType = _getResourceType(file.path);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload'),
      );

      // Add form fields
      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] = ref.replaceAll('/', '_'); // Replace slashes for valid public_id
      request.fields['overwrite'] = 'true';

      // Add resource type specific settings
      if (resourceType == 'video') {
        request.fields['resource_type'] = 'video';
      } else if (resourceType == 'raw') {
        request.fields['resource_type'] = 'raw';
      }

      // Add the file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = String.fromCharCodes(responseData);
        var jsonResult = jsonDecode(result);

        String downloadUrl = jsonResult['secure_url'];
        print('✅ Cloudinary upload successful: $downloadUrl');
        return downloadUrl;
      } else {
        var responseData = await response.stream.toBytes();
        var errorResult = String.fromCharCodes(responseData);
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        print('❌ Error: $errorResult');
        throw Exception('Failed to upload file to Cloudinary');
      }
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  String _getResourceType(String filePath) {
    String extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
        return 'raw'; // Audio files go to 'raw' resource type
      default:
        return 'raw'; // Default for unknown file types
    }
  }

  // Method to maintain compatibility with existing code
  Future<String> storeFileToFirebase(String ref, File file) async {
    // This maintains the same method name for easy replacement
    return await storeFileToCloudinary(ref, file);
  }
}
