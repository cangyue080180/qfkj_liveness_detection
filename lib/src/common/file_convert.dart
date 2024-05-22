

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui';
import "package:image/image.dart" as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';

const int limitSize = 31 * 1024;
class FileConvert {

  static Future<String?> compressAndConvertToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      return null;
    }

    Uint8List? zoomOut = await compressImage(imageFile);
    if (zoomOut == null) {
      return null;
    }
    String base64String = base64Encode(zoomOut);

    if (base64String.isEmpty) {
      return null;
    }
    int base64StringSize = base64String.length;
    int quality = 95;
    Uint8List? compressedBytes = zoomOut;
    while (base64StringSize > limitSize && quality > 15) {
      compressedBytes = await FlutterImageCompress.compressWithList(zoomOut, quality: quality);
      if (compressedBytes == null) {
        break;
      }
      base64StringSize = base64Encode(compressedBytes).length;
      quality -= 5;
    }
    if (compressedBytes == null || compressedBytes.isEmpty) {
      return null;
    }

    return base64Encode(compressedBytes);
  }


  static Future<Uint8List?> compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) {
      return null;
    }

    double aspectRatio = (image.height > image.width ? image.height : image.width) / 100;
    img.Image? resized = img.copyResize(image, width: image.width ~/ aspectRatio, height: image.height ~/ aspectRatio);
    return img.encodeJpg(resized);
  }

  static Future<String?> imageToBase64String(File imageFile) async {
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