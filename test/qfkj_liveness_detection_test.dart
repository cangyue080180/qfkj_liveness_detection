import 'package:flutter_test/flutter_test.dart';
import 'package:qfkj_liveness_detection/index.dart';
import 'package:qfkj_liveness_detection/src/vo/comparison_video_request.dart';

void main() {
  // testWidgets('finds a Text widget', (WidgetTester tester) async {
  //   // 创建一个测试用的widget
  //   await tester.pumpWidget(MaterialApp(
  //     home: Scaffold(
  //       body: Builder(
  //         builder: (BuildContext context) {
  //           // 在Builder的构建方法中，context是可用的
  //           // 你可以直接使用这个context，或者将其传递给其他方法
  //
  //           final response = await QfkjLivenessDetection.instance.detectLivelyness(
  //             context,
  //             config: DetectionConfig(
  //               steps: [
  //                 LivelynessStepItem(
  //                   step: LivelynessStep.blink,
  //                   title: "眨眼",
  //                   isCompleted: false,
  //                 ),
  //                 LivelynessStepItem(
  //                   step: LivelynessStep.smile,
  //                   title: "微笑",
  //                   isCompleted: false,
  //                 ),
  //               ],
  //               startWithInfoScreen: true,
  //             ),
  //           );
  //
  //           // 返回一个用于测试的widget
  //           return Text(response?.imgPath);
  //         },
  //       ),
  //     ),
  //   ));
  //
  //   // 通过WidgetTester，我们可以找到我们创建的Text widget来验证它是否存在
  //   expect(find.text('800.0'), findsOneWidget); // 假设屏幕宽度是800像素
  // });

  test('adds one to input values', () async {
    /*var test = await QfkjLivenessDetection.instance.protraitComparisonForPhoto(ClientInfo(clientId: "renxiangc2", clientSecret: "062e58fdb8296180"), ComparisonRequest(id:"1", name:"test", data:"wdfrhhh"));
     print(test.toString());*/

   /* var test2 = await QfkjLivenessDetection.instance.portraitComparisonForPhoto(
        ClientInfo(clientId: "renxiangc2", clientSecret: "062e58fdb8296180"),
        ComparisonRequest(id: "1", name: "test", photo: "wdfrhhh"), false);
    print(test2.data);*/


    var testNonLive = await QfkjLivenessDetection.instance.portraitComparisonForPhoto(
        ClientInfo(clientId: "renxiangc2", clientSecret: "062e58fdb8296180"),
        ComparisonRequest(id: "1", name: "test", photo: "wdfrhhh"), true);

    print(testNonLive.data);

  /*  FileConvert.compressImage(File("/Users/cli3/人脸识别code/test/88e1fada-3d17-4476-9ed8-2480373e1aa5.jpg"));

    var testSize = await FileConvert.imageToBase64String(File("/Users/cli3/人脸识别code/test/88e1fada-3d17-4476-9ed8-2480373e1aa5.jpg"));
    print(testSize?.length ?? 0);*/

    var test3 = await QfkjLivenessDetection.instance.portraitComparisonForPhotoPath(
        ClientInfo(clientId: "yzxbn240607", clientSecret: "e3620948979f5f74"),
        "1", "ceshi","/Users/cli3/人脸识别code/test/8aab13e9-b715-4d31-a0d2-bd0c1ba99a7f.jpg", true);
    print(test3.toString());

    var test4 = await QfkjLivenessDetection.instance.portraitComparisonForVideo(
        ClientInfo(clientId: "renxiangc2", clientSecret: "062e58fdb8296180"),
        ComparisonVideoRequest(id: "1", name: "test", video: "wdfrhhh"));
    print(test4.toString());

    // var re = await QfkjLivenessDetection.instance.portraitComparisonForVideoPath(
    //         ClientInfo(clientId: "xxx", clientSecret: "xxx"),
    //         id: "xx",
    //         name: "xx",
    //         videoPath: "xxx");
  });
}



