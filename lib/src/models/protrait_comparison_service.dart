
import 'dart:convert';
import 'dart:io';


import '../http/http_service.dart';
import '../vo/ClientInfo.dart';
import '../vo/ComparisonResponse.dart';
import '../vo/authentication_request.dart';
import '../vo/comparison_video_request.dart';
import '../vo/response.dart';
import '../vo/token.dart';
import 'package:http/http.dart' as http;



class PortraitComparisonService {

  // Using lowerCamelCase for constant names as per Dart guidelines

// Base URL for the Portrait Comparison Service
  static const String portraitComparisonServiceBaseUrl = "https://yzy.iotseal.cn";

// Path to get the token
  static const String getTokenPath = "/gt/interface-service/third/security/token";

// Path for image comparison
  static const String imageComparisonPath = "/gt/interface-service/third/security/portrait/verasktoqclive";

  static const String imageComparisonPathNonLive = "/gt/interface-service/third/security/portrait/verasktoqc";


// Path for video comparison
  static const String videoComparisonPath = "/gt/interface-service/third/security/compare/videoComparison";


  late HttpService httpService;
  PortraitComparisonService() {
    httpService = HttpService(portraitComparisonServiceBaseUrl);
  }


  Future<Response<Data?>> portraitComparisonForPhoto(
      ClientInfo clientInfo, ComparisonRequest data, bool nonLive) async {
    try {
      final tokenResponse = await httpService.post(
        getTokenPath,
        data: clientInfo,
      );

      if (tokenResponse.body != null) {
        final token = Token
            .fromJson(jsonDecode(tokenResponse.body))
            .accessToken;

        if (token != null) {
          final path = nonLive ? imageComparisonPathNonLive : imageComparisonPath;
          final authResponse = await httpService.post(
            path,
            headers: {
              'token': token
            },
            data: data,
          );

          var comparisonResponse = ComparisonResponse.fromJson(
              jsonDecode(authResponse.body));
          return Response(msg: comparisonResponse.msg??"unKnown",
              status: comparisonResponse.code == 0 ? Status.success : Status.compareError,
              data: comparisonResponse.data);
        } else {
          return Response(msg: "get token fail", status: Status.tokenError);
        }
      } else {
        return Response(msg: "get token service fail", status: Status.tokenError);
      }
    } catch (e) {
      return Response(msg: e.toString(), status: Status.error);
    }
  }


  Future<Response<Data?>> portraitComparisonForVideo(
      ClientInfo clientInfo, ComparisonVideoRequest data) async {
    try {
      final tokenResponse = await httpService.post(
        getTokenPath,
        data: clientInfo,
      );

      if (tokenResponse.body != null) {
        final token = Token
            .fromJson(jsonDecode(tokenResponse.body))
            .accessToken;

        if (token != null) {
          final authResponse = await httpService.post(
            videoComparisonPath,
            headers: {
              'token': token
            },
            data: data,
          );

          var comparisonResponse = ComparisonResponse.fromJson(
              jsonDecode(authResponse.body));
          return Response(msg: comparisonResponse.msg??"unKnown",
              status: comparisonResponse.code == 0 ? Status.success : Status.compareError,
              data: comparisonResponse.data);
        } else {
          return Response(msg: "get token fail", status: Status.tokenError);
        }
      } else {
        return Response(msg: "get token service fail", status: Status.tokenError);
      }
    } catch (e) {
      return Response(msg: e.toString(), status: Status.error);
    }
  }

}