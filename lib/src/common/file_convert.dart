

import 'dart:convert';
import 'dart:io';

class FileConvert {
  static Future<String?> imageToBase64String(String imagePath) async {
    File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      return null;
    }
    final imageBytes = await imageFile.readAsBytes();
    final base64String = base64Encode(imageBytes);
    return base64String;
  }

  static Future<String?> videoFileToBase64(String videoPath) async {
    final file = File(videoPath);
    if (!await file.exists()) {
      return null;
    }
    final videoBytes = await file.readAsBytes();
    final videoBase64 = base64Encode(videoBytes);
    return videoBase64;
  }

}