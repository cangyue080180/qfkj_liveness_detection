library qfkj_liveness_detection;

import 'package:m7_livelyness_detection/index.dart';
import 'package:qfkj_liveness_detection/src/api/qfkj_liveness_detection_api.dart';
import 'package:qfkj_liveness_detection/src/common/file_convert.dart';
import 'package:qfkj_liveness_detection/src/common/mapper.dart';
import 'package:qfkj_liveness_detection/src/models/protrait_comparison_service.dart';
import 'package:qfkj_liveness_detection/src/vo/ClientInfo.dart';
import 'package:qfkj_liveness_detection/src/vo/ComparisonResponse.dart';
import 'package:qfkj_liveness_detection/src/vo/authentication_request.dart';
import 'package:qfkj_liveness_detection/src/vo/caputred_image.dart';
import 'package:qfkj_liveness_detection/src/vo/comparison_video_request.dart';
import 'package:qfkj_liveness_detection/src/vo/detection_config.dart';
import 'package:qfkj_liveness_detection/src/vo/detection_threshold.dart';
import 'package:qfkj_liveness_detection/src/vo/response.dart';

class QfkjLivenessDetection implements QfkjLivenessDetectionApi {
  QfkjLivenessDetection._privateConstructor();

  static final QfkjLivenessDetection instance =
      QfkjLivenessDetection._privateConstructor();

  late final PortraitComparisonService protraitComparisonService =
      PortraitComparisonService();

  /// Configures the shreshold values of which will be used while verfying
  /// Parameters: -
  /// * thresholds: - List of [DetectionThreshold] objects.
  /// * contourColor - Color of the points that are plotted on the face while detecting.
  @override
  void configure(
      {required List<DetectionThreshold> thresholds,
      Color lineColor = const Color(0xffab48e0),
      Color dotColor = const Color(0xffab48e0),
      double lineWidth = 1.6,
      double dotSize = 2.0,
      bool displayLines = true,
      bool displayDots = true,
      List<double>? dashValues}) {
    M7LivelynessDetection.instance.configure(
        thresholds: Mapper.mapToM7Threshold(thresholds),
        lineColor: lineColor,
        dotColor: dotColor,
        lineWidth: lineWidth,
        dotSize: dotSize,
        displayLines: displayLines,
        displayDots: displayDots,
        dashValues: dashValues);
  }

  /// A single line functoin to detect weather the face is live or not.
  /// Parameters: -
  /// * context: - Positional Parameter that will accept a `BuildContext` using which it will redirect the a new screen.
  /// * config: - Accepts a `DetectionConfig` object which will hold all the setup config of the package.
  @override
  Future<CapturedImage?> detectLivelyness(BuildContext context,
      {required DetectionConfig config}) async {
    final capturedImage = await M7LivelynessDetection.instance.detectLivelyness(
        context,
        config: M7DetectionConfig(
            steps: Mapper.mapToM7StepItem(config.steps),
            startWithInfoScreen: config.startWithInfoScreen,
            maxSecToDetect: config.maxSecToDetect,
            allowAfterMaxSec: config.allowAfterMaxSec,
            captureButtonColor: config.captureButtonColor));
    return Future(() => capturedImage != null
        ? CapturedImage(
            imgPath: capturedImage.imgPath,
            didCaptureAutomatically: capturedImage.didCaptureAutomatically)
        : null);
  }

  @override
  Future<Response<Data?>> portraitComparisonForPhoto(
      ClientInfo clientInfo, ComparisonRequest data) {
    return protraitComparisonService.portraitComparisonForPhoto(
        clientInfo, data);
  }

  @override
  Future<Response<Data?>> portraitComparisonForVideo(
      ClientInfo clientInfo, ComparisonVideoRequest data) {
    return protraitComparisonService.portraitComparisonForVideo(
        clientInfo, data);
  }

  @override
  Future<Response<Data?>> portraitComparisonForPhotoPath(
      ClientInfo clientInfo, String id, String name, String photoPath) async {
    try {
      String? photoData = await FileConvert.imageToBase64String(photoPath);
      if (photoData != null) {
        return protraitComparisonService.portraitComparisonForPhoto(
            clientInfo, ComparisonRequest(id: id, name: name, photo: photoData));
      } else {
        return Response(status: Status.requestError, msg: "photoPath error");
      }
    } catch (e) {
      return Response(status: Status.error, msg: e.toString());
    }
  }

  @override
  Future<Response<Data?>> portraitComparisonForVideoPath(
      ClientInfo clientInfo, String id, String name, String videoPath) async {
    try {
      String? videoData = await FileConvert.videoFileToBase64(videoPath);
      if (videoData != null) {
        return protraitComparisonService.portraitComparisonForVideo(
            clientInfo, ComparisonVideoRequest(id: id, name: name, video: videoData));
      } else {
        return Response(status: Status.requestError, msg: "videoPath error");
      }
    } catch (e) {
      return Response(status: Status.error, msg: e.toString());
    }
  }
}
