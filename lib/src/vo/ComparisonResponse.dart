import 'dart:convert';

class ComparisonResponse {
  late int _code;
  late String? _msg;
  late Data? _data;

  ComparisonResponse({
    required int code,
    String? msg,
    Data? data,
  }) {
    _code = code;
    _msg = msg;
    _data = data;
  }

  ComparisonResponse.fromJson(dynamic json) {
    _code = json['code'];
    _msg = json['msg'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  int get code => _code;
  String? get msg => _msg;
  Data? get data => _data;

  ComparisonResponse copyWith({
    required int code,
    required String msg,
    Data? data,
  }) =>
      ComparisonResponse(
        code: code ,
        msg: msg,
        data: data ?? _data,
      );
}

class Data {
  late IdentityVerificationResult _flag;
    //在 flag 为 0 时 非空：
    //1. -1未存储照片或视频提取人脸不符合比对质量要求
   //2. 0%- 100% 的数值，相似度百分比
  late String? _similarity;
  late String? _sn;
  late String? _signs;

  Data({
    required IdentityVerificationResult flag,
    required String? similarity,
    required String? sn,
    required String? signs
  }) {
    _flag = flag;
    _similarity = similarity;
    _sn = sn;
    _signs = signs;
  }

  Data.fromJson(dynamic json) {
    _flag = StringToEnum(json['flag']);
    _similarity = json['similarity'];
    _sn = json['sn'];
    _signs = json['signs'];
  }

   IdentityVerificationResult StringToEnum(String? code) {
    if (code == null) {
      return IdentityVerificationResult.unKnown;
    } else {
      switch (code) {
        case "0":
          return IdentityVerificationResult.consistent;
        case "1":
          return IdentityVerificationResult.inconsistentInfo;
        case "2":
          return IdentityVerificationResult.noInformationFound;
        case "3":
          return IdentityVerificationResult.nonLiveVideo;
        case "4":
          return IdentityVerificationResult.noPortraitDetected;
        default:
          return IdentityVerificationResult.unKnown;
      }
    }
  }

  IdentityVerificationResult get flag => _flag;
  String? get similarity => _similarity;
  String? get sn => _sn;

}

enum IdentityVerificationResult {
  consistent, // 身份证号与姓名均一致
  inconsistentInfo, // 身份证号一致，姓名或视频不一致
  noInformationFound, // 未查到对应信息
  nonLiveVideo, // 提交视频非活体
  noPortraitDetected, // 未检测到人像
  unKnown
}
