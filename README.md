一个人脸识别库，提供识别，比对功能

## Environment
    sdk: ">=2.18.6 <3.0.0"  
    flutter: ">=2.5.0"

## Getting started

有两种方式：
1. 本地路径依赖
~~~
  dependencies:
  qfkj_liveness_detection:
  path: ../path/qfkj_liveness_detection
~~~

2. Git依赖
~~~
dependencies:
  qfkj_liveness_detection:
    git:
      url: git@github.com:yourusername/qfkj_liveness_detection.git
      ref: master
~~~

## Import
```dart
import 'package:qfkj_liveness_detection/index.dart';
```

## Usage
### 函数名: `detectLivelyness`
```dart
  Future<CapturedImage?> detectLivelyness(BuildContext context,
        {required DetectionConfig config}) async {
  }
```

- 描述: 

此函数用于检测面部是否活跃。它会根据传入的配置，在相应平台(iOS或Android)上打开面部活跃度检测页面，并返回检测到的面部图像路径。

- 参数:
1. `BuildContext context`: 位置参数，需要传递一个`BuildContext`对象，用于页面导航。
2. `DetectionConfig config`: 命名参数，必需。接受一个`DetectionConfig`对象，该对象包含了面部活跃度检测所需的所有配置信息,以及配置的检测步骤。

```.dart
  class DetectionConfig {
    /// 检测人脸时要添加的检查类型。
    final List<LivelynessStepItem> steps;

    /// 一个布尔值，用于定义检测是否应该以“Info”屏幕开始。
    /// 默认为 *false*
    final bool startWithInfoScreen;

    /// 人脸检测完成的时间。
    /// 默认为 *15*
    final int maxSecToDetect;

    /// 一个布尔值，定义是否允许用户在没有检测到人脸的情况下点击自拍。
    final bool allowAfterMaxSec;

    /// [maxSecToDetect]完成后按钮的图标颜色。
    final Color? captureButtonColor;
   } 
   
   class LivelynessStepItem {
    final LivelynessStep step;
    final String title;
    final double? thresholdToCheck;
    final bool isCompleted;
    final Color? detectionColor;
  }
  
  enum LivelynessStep {
    blink,
    turnLeft,
    turnRight,
    smile,
  }
```

- 返回值: 

`Future<CapturedImage?>` 异步返回一个`CapturedImage`对象，包含捕获的面部图像路径。如果用户取消或未检测到面部，可能返回null。

- 使用示例：

```.dart
  final response = await QfkjLivenessDetection.instance.detectLivelyness(
      context,
      config: DetectionConfig(
        steps: [
          LivelynessStepItem(
            step: LivelynessStep.blink,
            title: "眨眼",
            isCompleted: false,
          ),
          LivelynessStepItem(
            step: LivelynessStep.smile,
            title: "微笑",
            isCompleted: false,
          ),
        ],
        startWithInfoScreen: true,
      ),
    );
```

### 函数名: `configure`
- 描述: 

用于配置检测阈值、点和线的颜色、大小以及是否显示点和线。

- 参数: 

`List thresholds`: 必需。阈值列表，包含多个`DetectionThreshold`对象, 例如：`BlinkDetectionThreshold`, `SmileDetectionThreshold`, `HeadTurnDetectionThreshold`。

`Color lineColor`: 线的颜色，默认为紫色`Color(0xffab48e0)`。

`Color dotColor`: 点的颜色，默认为紫色`Color(0xffab48e0)`。

`double lineWidth`: 线的宽度，默认为`1.6`。

`double dotSize`: 点的大小，默认为`2.0`。

`bool displayLines`: 是否显示线，默认为`true`。

`bool displayDots`: 是否显示点，默认为`true`。

`List? dashValues`: 虚线的数组，必须包含两个值，否则将忽略此配置。可选。


- 返回值:

此接口无返回值。

- 使用示例：

```dart
List<DetectionThreshold> thresholds = [...]; /// 配置你的阈值
QfkjLivenessDetection.instance.configure(
thresholds: thresholds,
lineColor: Colors.blue,
dotColor: Colors.red,
lineWidth: 2.0,
dotSize: 3.0,
displayLines: true,
displayDots: true,
dashValues: [5.0, 2.5],)
```

### 函数名：`portraitComparisonForPhoto`
- 描述：

接收请求方提交的被认证人的公民身份证号码、姓名和照片，在照片为活体采集，公民身份号码、姓名认证“一致”的情况下，平台进一步将用户提交的被认证人活体照片与存储的照片进行比对，返回认证结果及人脸相似度值。

- 参数：

`clientInfo: ClientInfo` ：客户端信息对象，包含客户端相关信息。

`data: ComparisonRequest` ： 比对请求数据，包括待比对的照片等信息。

`nonLive: bool` ： 是否包含活体检测， false 包含活体检测，true 不包含活体检测

- 返回值：

`Future<Response<Data?>>` ：异步结果，返回比对结果的响应对象

参数详细说明：
~~~.dart
class ClientInfo {
  final String clientId; /// 分配的id
  final String clientSecret; /// 分配的secret
}
class ComparisonRequest{
  final String id;///公民身份证号码，不可为空
  final String name;///公民姓名，不可为空
  final String data;///photoBase64后的数据，不可为空
}
~~~
返回值详细说明：
~~~.dart
enum Status {
  success,/// 成功
  requestError,///请求错误
  tokenError,///token错误
  compareError,///比较失败
  error,///错误
  unknown///未知错误
}
class Response{
  final Status status;/// Status
  final String msg;///返回消息
  final Data? data;///请求结果
}
class Data {
  /// 比对结果，不为空
  late IdentityVerificationResult _flag;
  ///相似度 在 flag为 0时 非空:
  ///1. -1 未存储照 片或照片不符合比对质量要求
  ///2. 0%- 100% 的数值 ，相似度百分比
  late String? _similarity;
  ///电子档案号，不为空
  late String _sn;
  ///签名值 活体控件获取的签名值 不为空
  late String _signs;
}
enum IdentityVerificationResult {
  consistent, /// 身份证号与姓名均一致
  inconsistentInfo, /// 身份证号一致，姓名或视频不一致
  noInformationFound, /// 未查到对应信息
  nonLiveVideo, /// 提交视频非活体
  noPortraitDetected /// 未检测到人像
}
~~~

- 使用示例

```dart
var response = await QfkjLivenessDetection.instance.portraitComparisonForPhoto(
ClientInfo(clientId: "renxiangc2", clientSecret: "062e58fdb8296180"),
ComparisonRequest(id: "1", name: "test", data: "photoBase64后的数据"));
```

### 函数名：`portraitComparisonForVideo`
- 描述:
  接收请求方提交的被认证人的公民身份证号码、姓名和照片，在照片为活体采集，公民身份号码、姓名认证“一致”的情况下，平台进一步将用户提交的被认证人活体照片与存储的照片进行比对，返回认证结果及人脸相似度值。
- 参数：

`clientInfo: ClientInfo` ：客户端信息对象，包含客户端相关信息。

`data: ComparisonRequest` ： 比对请求数据，包括待比对的照片等信息。

- 返回值：

`Future<Response<Data?>>` ：异步结果，返回比对结果的响应对象

参数详细说明：
~~~.dart
class ClientInfo {
  final String clientId; /// 分配的id
  final String clientSecret; /// 分配的secret
}
class ComparisonRequest{
  final String id;///公民身份证号码，不可为空
  final String name;///公民姓名，不可为空
  final String data;///videoBase64后的数据，不可为空
}
~~~
返回值详细说明：
~~~.dart
enum Status {
  success,/// 成功
  requestError,///请求错误
  tokenError,///token错误
  compareError,///比较失败
  error,///错误
  unknown///未知错误
}
class Response{
  final Status status;/// Status
  final String msg;///返回消息
  final Data? data;///请求结果
}
class Data {
  /// 比对结果，不为空
  late IdentityVerificationResult _flag;
  ///相似度 在 flag为 0时 非空:
  ///1. -1 未存储照 片或照片不符合比对质量要求
  ///2. 0%- 100% 的数值 ，相似度百分比
  late String? _similarity;
  ///电子档案号，不为空
  late String _sn;
  ///签名值 活体控件获取的签名值 不为空
  late String _signs;
}
enum IdentityVerificationResult {
  consistent, /// 身份证号与姓名均一致
  inconsistentInfo, /// 身份证号一致，姓名或视频不一致
  noInformationFound, /// 未查到对应信息
  nonLiveVideo, /// 提交视频非活体
  noPortraitDetected /// 未检测到人像
}
~~~
- 使用示例：

```dart
var response = await QfkjLivenessDetection.instance.portraitComparisonForVideo(
        ClientInfo(clientId: "xxx", clientSecret: "xxx"),
        ComparisonRequest(id: "xx", name: "xx", data: "videoBase64后的数据"));
```

### 函数名：`portraitComparisonForPhotoPath`

~~~.dart
  Future<Response<Data?>> portraitComparisonForPhotoPath(
      ClientInfo clientInfo, String id, String name, String photoPath) async { 
      
  }
~~~

- 描述:
  接收请求方提交的被认证人的公民身份证号码、姓名和照片，在照片为活体采集，公民身份号码、姓名认证“一致”的情况下，平台进一步将用户提交的被认证人活体照片与存储的照片进行比对，返回认证结果及人脸相似度值。
- 参数：

`clientInfo: ClientInfo` ：客户端信息对象，包含客户端相关信息。

`id: String` ： 公民身份证号码，不可为空。

`name: String` ： 公民姓名，不可为空。

`photoPath: String` ： 照片路径，不可为空。

`nonLive: bool` ： 是否包含活体检测， false 包含活体检测，true 不包含活体检测

- 返回值：

`Future<Response<Data?>>` ：异步结果，返回比对结果的响应对象

参数详细说明：
~~~.dart
class ClientInfo {
  final String clientId; /// 分配的id
  final String clientSecret; /// 分配的secret
}
~~~
返回值详细说明：
~~~.dart
enum Status {
  success,/// 成功
  requestError,///请求错误
  tokenError,///token错误
  compareError,///比较失败
  error,///错误
  unknown///未知错误
}
class Response{
  final Status status;/// Status
  final String msg;///返回消息
  final Data? data;///请求结果
}
class Data {
  /// 比对结果，不为空
  late IdentityVerificationResult _flag;
  ///相似度 在 flag为 0时 非空:
  ///1. -1 未存储照 片或照片不符合比对质量要求
  ///2. 0%- 100% 的数值 ，相似度百分比
  late String? _similarity;
  ///电子档案号，不为空
  late String _sn;
  ///签名值 活体控件获取的签名值 不为空
  late String _signs;
}
enum IdentityVerificationResult {
  consistent, /// 身份证号与姓名均一致
  inconsistentInfo, /// 身份证号一致，姓名或视频不一致
  noInformationFound, /// 未查到对应信息
  nonLiveVideo, /// 提交视频非活体
  noPortraitDetected /// 未检测到人像
}
~~~
- 使用示例：

```dart
var response = await QfkjLivenessDetection.instance
        .portraitComparisonForPhotoPath(
ClientInfo(clientId: "xxx", clientSecret: "xxx"),
id: "xx",
name: "xx",
photoPath: "xxx");
```

### 函数名：`portraitComparisonForVideoPath`

~~~.dart
  Future<Response<Data?>> portraitComparisonForVideoPath(
      ClientInfo clientInfo, String id, String name, String videoPath) async {
      
  }
~~~
- 描述:
  接收请求方提交的被认证人的公民身份证号码、姓名和照片，在照片为活体采集，公民身份号码、姓名认证“一致”的情况下，平台进一步将用户提交的被认证人活体照片与存储的照片进行比对，返回认证结果及人脸相似度值。
- 参数：

`clientInfo: ClientInfo` ：客户端信息对象，包含客户端相关信息。

`id: String` ： 公民身份证号码，不可为空。

`name: String` ： 公民姓名，不可为空。

`videoPath: String` ： 视频路径，不可为空。

- 返回值：

`Future<Response<Data?>>` ：异步结果，返回比对结果的响应对象

参数详细说明：
~~~.dart
class ClientInfo {
  final String clientId; /// 分配的id
  final String clientSecret; /// 分配的secret
}
~~~
返回值详细说明：
~~~.dart
enum Status {
  success,/// 成功
  requestError,///请求错误
  tokenError,///token错误
  compareError,///比较失败
  error,///错误
  unknown///未知错误
}
class Response{
  final Status status;/// Status
  final String msg;///返回消息
  final Data? data;///请求结果
}
class Data {
  /// 比对结果，不为空
  late IdentityVerificationResult _flag;
  ///相似度 在 flag为 0时 非空:
  ///1. -1 未存储照 片或照片不符合比对质量要求
  ///2. 0%- 100% 的数值 ，相似度百分比
  late String? _similarity;
  ///电子档案号，不为空
  late String _sn;
  ///签名值 活体控件获取的签名值 不为空
  late String _signs;
}
enum IdentityVerificationResult {
  consistent, /// 身份证号与姓名均一致
  inconsistentInfo, /// 身份证号一致，姓名或视频不一致
  noInformationFound, /// 未查到对应信息
  nonLiveVideo, /// 提交视频非活体
  noPortraitDetected /// 未检测到人像
}
~~~
- 使用示例：

```dart
var response = await QfkjLivenessDetection.instance
        .portraitComparisonForVideoPath(
ClientInfo(clientId: "xxx", clientSecret: "xxx"),
id: "xx",
name: "xx",
videoPath: "xxx");
```

