import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:giphy_get/giphy_get.dart'; // Add this dependency

void showSnackbar({
  required BuildContext context,
  required String content,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
  }
  return image;
}

// ✅ ADD: Missing pickVideoFromGallery method
Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
  }
  return video;
}

// ✅ ADD: Missing pickGIF method
Future<GiphyGif?> pickGIF(BuildContext context) async {
  try {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: 'YOUR_GIPHY_API_KEY', // Get free API key from giphy.com
      lang: GiphyLanguage.english,
    );
    return gif;
  } catch (e) {
    showSnackbar(context: context, content: e.toString());
    return null;
  }
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Select Image Source'),
      content: const Text('Choose where to pick the image from'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'camera'),
          child: const Text('Camera'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'gallery'),
          child: const Text('Gallery'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  ).then((String? source) async {
    if (source == 'camera') {
      image = await pickImageFromCamera(context);
    } else if (source == 'gallery') {
      image = await pickImageFromGallery(context);
    }
  });
  return image;
}
