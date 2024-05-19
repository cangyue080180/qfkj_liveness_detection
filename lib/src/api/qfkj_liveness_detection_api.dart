
import 'dart:ffi';

import 'package:m7_livelyness_detection/index.dart';

import '../vo/ClientInfo.dart';
import '../vo/ComparisonResponse.dart';
import '../vo/authentication_request.dart';
import '../vo/caputred_image.dart';
import '../vo/comparison_video_request.dart';
import '../vo/detection_config.dart';
import '../vo/detection_threshold.dart';
import '../vo/response.dart';


class QfkjLivenessDetectionApi {

  Future<CapturedImage?> detectLivelyness(
      BuildContext context, {
        required DetectionConfig config,
      }) {
     throw Exception("not implement error");
  }

  void configure({
    required List<DetectionThreshold> thresholds,
    Color lineColor = const Color(0xffab48e0),
    Color dotColor = const Color(0xffab48e0),
    double lineWidth = 1.6,
    double dotSize = 2.0,
    bool displayLines = true,
    bool displayDots = true,
    List<double>? dashValues,
  }) {}

  Future<Response<Data?>> portraitComparisonForPhoto(
      ClientInfo clientInfo, ComparisonRequest data, bool nonLive) {
    throw Exception("not implement error");
  }

  Future<Response<Data?>> portraitComparisonForVideo(
      ClientInfo clientInfo, ComparisonVideoRequest data) {
    throw Exception("not implement error");
  }

  Future<Response<Data?>> portraitComparisonForPhotoPath(
      ClientInfo clientInfo, String id, String name, String photoPath, bool nonLive) {
    throw Exception("not implement error");
  }

  Future<Response<Data?>> portraitComparisonForVideoPath(
      ClientInfo clientInfo, String id, String name, String videoPath) {
    throw Exception("not implement error");
  }

}