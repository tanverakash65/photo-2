import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CloudinaryService {
  static const String cloudName = 'dc6j57sq0';
  static const String uploadPreset = 'user_profiles';

  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      print('🌤️ Starting Cloudinary upload...');
      print('🌤️ Cloud Name: $cloudName');
      print('🌤️ Upload Preset: $uploadPreset');
      print('🌤️ User ID: $userId');
      print('🌤️ Image Path: ${imageFile.path}');
      print('🌤️ Image Exists: ${await imageFile.exists()}');

      if (!await imageFile.exists()) {
        print('❌ Image file does not exist!');
        return null;
      }

      // Check file size
      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      print('🌤️ Image Size: ${fileSizeInMB.toStringAsFixed(2)} MB');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      // Add form fields
      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] = 'profiles/user_$userId';
      request.fields['overwrite'] = 'true';

      print('🌤️ Request fields: ${request.fields}');

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      print('🌤️ Image file added to request');

      // Send request
      print('🌤️ Sending request to Cloudinary...');
      var response = await request.send();
      print('🌤️ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = String.fromCharCodes(responseData);
        print('🌤️ Response data: $result');

        var jsonResult = jsonDecode(result);
        String imageUrl = jsonResult['secure_url'];
        print('✅ Cloudinary upload successful: $imageUrl');
        return imageUrl;
      } else {
        // Get detailed error information
        var responseData = await response.stream.toBytes();
        var errorResult = String.fromCharCodes(responseData);
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        print('❌ Error response: $errorResult');

        // Try to parse error JSON
        try {
          var errorJson = jsonDecode(errorResult);
          print('❌ Error details: ${errorJson['error']?.toString() ?? 'Unknown error'}');
        } catch (e) {
          print('❌ Could not parse error JSON');
        }

        return null;
      }
    } catch (e) {
      print('❌ Cloudinary upload exception: $e');
      print('❌ Exception type: ${e.runtimeType}');
      return null;
    }
  }
}
