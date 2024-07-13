import 'dart:async';

import 'package:m7_livelyness_detection/index.dart';
import 'package:flutter/cupertino.dart';

class M7LivelynessDetectionPageV2 extends StatelessWidget {
  final M7DetectionConfig config;

  const M7LivelynessDetectionPageV2({
    required this.config,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: M7LivelynessDetectionScreenV2(
          config: config,
        ),
      ),
    );
  }
}

class M7LivelynessDetectionScreenV2 extends StatefulWidget {
  final M7DetectionConfig config;

  const M7LivelynessDetectionScreenV2({
    required this.config,
    super.key,
  });

  @override
  State<M7LivelynessDetectionScreenV2> createState() =>
      _M7LivelynessDetectionScreenAndroidState();
}

class _M7LivelynessDetectionScreenAndroidState extends State<
    M7LivelynessDetectionScreenV2> /* with SingleTickerProviderStateMixin*/ {
  //* MARK: - Private Variables
  //? =========================================================
  final _faceDetectionController = BehaviorSubject<FaceDetectionModel>();

  final options = FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
    enableTracking: true,
    enableLandmarks: true,
    performanceMode: FaceDetectorMode.accurate,
    minFaceSize: 0.05,
  );
  late final faceDetector = FaceDetector(options: options);
  bool _didCloseEyes = false;
  bool _isProcessingStep = false;

  late final List<M7LivelynessStepItem> _steps;
  final GlobalKey<M7LivelynessDetectionStepOverlayState> _stepsKey =
      GlobalKey<M7LivelynessDetectionStepOverlayState>();

  CameraState? _cameraState;
  bool _isProcessing = false;
  late bool _isInfoStepCompleted;
  Timer? _timerToDetectFace;
  bool _isCaptureButtonVisible = false;
  bool _isCompleted = false;
  bool alreadyOnComplete = false;

  //* MARK: - Life Cycle Methods
  //? =========================================================
  @override
  void initState() {
    _preInitCallBack();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _postFrameCallBack(),
    );
  }

  @override
  void deactivate() {
//    print("${DateTime.now()}, deactivate faceDetector.close");
    faceDetector.close();
    super.deactivate();
  }

  @override
  void dispose() {
//    print("${DateTime.now()}, dispose");
    _faceDetectionController.close();
    _timerToDetectFace?.cancel();
    _timerToDetectFace = null;
    super.dispose();
  }

  //* MARK: - Private Methods for Business Logic
  //? =========================================================
  void _preInitCallBack() {
    _steps = widget.config.steps;
    _isInfoStepCompleted = !widget.config.startWithInfoScreen;
  }

  void _postFrameCallBack() {
    if (_isInfoStepCompleted) {
      _startTimer();
    }
  }

  Future<void> _processCameraImage(AnalysisImage img) async {
    // print(
    //     "${DateTime.now()}, _processCameraImage _isProcessing $_isProcessing");
    if (_isProcessing) {
      return;
    }
    if (mounted) {
      setState(
        () => _isProcessing = true,
      );
    }
    final inputImage = img.toInputImage();

    try {
      // print(
      //     "${DateTime.now()}, _processCameraImage faceDetector.processImage BEGIN");
      final List<Face> detectedFaces =
          await faceDetector.processImage(inputImage);

      // print(
      //     "${DateTime.now()}, _processCameraImage faceDetector.processImage END");

      _faceDetectionController.add(
        FaceDetectionModel(
          faces: detectedFaces,
          absoluteImageSize: inputImage.inputImageData!.size,
          rotation: 0,
          imageRotation: img.inputImageRotation,
          croppedSize: img.croppedSize,
        ),
      );
      await _processImage(inputImage, detectedFaces);
      // print("${DateTime.now()}, _processImage _detect END");
      if (mounted) {
        setState(
          () => _isProcessing = false,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _isProcessing = false,
        );
      }
      debugPrint("...sending image resulted error $error");
    }
  }

  Future<void> _processImage(InputImage img, List<Face> faces) async {
    try {
      if (faces.isEmpty) {
        _resetSteps();
        return;
      }
      final Face firstFace = faces.first;
      if (_isProcessingStep &&
          _steps[_stepsKey.currentState?.currentIndex ?? 0].step ==
              M7LivelynessStep.blink) {
        if (_didCloseEyes) {
          if ((faces.first.leftEyeOpenProbability ?? 1.0) < 0.75 &&
              (faces.first.rightEyeOpenProbability ?? 1.0) < 0.75) {
            await _completeStep(
              step: _steps[_stepsKey.currentState?.currentIndex ?? 0].step,
            );
          }
        }
      }
      // print("${DateTime.now()}, _processImage _detect BEGIN");
      _detect(
        face: firstFace,
        step: _steps[_stepsKey.currentState?.currentIndex ?? 0].step,
      );
    } catch (e) {
      _startProcessing();
    }
  }

  Future<void> _completeStep({
    required M7LivelynessStep step,
  }) async {
    final int indexToUpdate = _steps.indexWhere(
      (p0) => p0.step == step,
    );

    _steps[indexToUpdate] = _steps[indexToUpdate].copyWith(
      isCompleted: true,
    );
    if (mounted) {
      setState(() {});
    }
    await _stepsKey.currentState?.nextPage();
    _stopProcessing();
  }

  void _detect({
    required Face face,
    required M7LivelynessStep step,
  }) async {
    switch (step) {
      case M7LivelynessStep.blink:
        const double blinkThreshold = 0.25;
        if ((face.leftEyeOpenProbability ?? 1.0) < (blinkThreshold) &&
            (face.rightEyeOpenProbability ?? 1.0) < (blinkThreshold)) {
          _startProcessing();
          if (mounted) {
            setState(
              () => _didCloseEyes = true,
            );
          }
        }
        break;
      case M7LivelynessStep.turnLeft:
        const double headTurnThreshold = -25.0;
//        print("${DateTime.now()} turnLeft ${face.headEulerAngleY}");
        if ((face.headEulerAngleY ?? 0) < (headTurnThreshold)) {
          _startProcessing();
          await _completeStep(step: step);
        }
        break;
      case M7LivelynessStep.turnRight:
        const double headTurnThreshold = 25.0;
        //       print("${DateTime.now()} turnRight ${face.headEulerAngleY}");
        if ((face.headEulerAngleY ?? 0) > (headTurnThreshold)) {
          _startProcessing();
          await _completeStep(step: step);
        }
        break;
      case M7LivelynessStep.smile:
        const double smileThreshold = 0.75;
//        print("${DateTime.now()} smile ${face.smilingProbability}");
        if ((face.smilingProbability ?? 0) > (smileThreshold)) {
          _startProcessing();
          await _completeStep(step: step);
        }
        break;
    }
  }

  void _startProcessing() {
    if (!mounted) {
      return;
    }
    setState(
      () => _isProcessingStep = true,
    );
  }

  void _stopProcessing() {
    if (!mounted) {
      return;
    }
    setState(
      () => _isProcessingStep = false,
    );
  }

  void _startTimer() {
    _timerToDetectFace = Timer(
      Duration(seconds: widget.config.maxSecToDetect),
      () {
        _timerToDetectFace?.cancel();
        _timerToDetectFace = null;
        if (widget.config.allowAfterMaxSec) {
          _isCaptureButtonVisible = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }
        _onDetectionCompleted(
          imgToReturn: null,
        );
      },
    );
  }

  Future<void> _takePicture({
    required bool didCaptureAutomatically,
  }) async {
    if (_cameraState == null) {
      _onDetectionCompleted();
      return;
    }
    _cameraState?.when(
      onPhotoMode: (p0) => Future.delayed(
        const Duration(milliseconds: 500),
        () => p0.takePhoto().then(
          (value) {
            _onDetectionCompleted(
              imgToReturn: value,
              didCaptureAutomatically: didCaptureAutomatically,
            );
          },
        ),
      ),
    );
  }

  void _onDetectionCompleted({
    String? imgToReturn,
    bool? didCaptureAutomatically,
  }) {
    if (_isCompleted) {
      return;
    }
    setState(
      () => _isCompleted = true,
    );
    final String imgPath = imgToReturn ?? "";

//    print("${DateTime.now()}, _onDetectionCompleted");
    if (imgPath.isEmpty || didCaptureAutomatically == null) {
      Navigator.of(context).pop(null);
      return;
    }
    Navigator.of(context).pop(
      M7CapturedImage(
        imgPath: imgPath,
        didCaptureAutomatically: didCaptureAutomatically,
      ),
    );
  }

  void _resetSteps() async {
    for (var p0 in _steps) {
      final int index = _steps.indexWhere(
        (p1) => p1.step == p0.step,
      );
      _steps[index] = _steps[index].copyWith(
        isCompleted: false,
      );
    }
    _didCloseEyes = false;
    if (_stepsKey.currentState?.currentIndex != 0) {
      _stepsKey.currentState?.reset();
    }
    if (mounted) {
      setState(() {});
    }
  }

  //* MARK: - Private Methods for UI Components
  //? =========================================================
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        _isInfoStepCompleted
            ? Align(
                alignment: Alignment(0.0, -1 / 3),
                child: ClipOval(
                  child: Container(
                    width: 260,
                    height: 260,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: CameraAwesomeBuilder.custom(
                        // enableAudio: false,
                        flashMode: FlashMode.auto,
                        zoom: 0.1,
                        previewFit: CameraPreviewFit.fitWidth,
                        aspectRatio: CameraAspectRatios.ratio_4_3,
                        sensor: Sensors.front,
                        progressIndicator: Center(
                          child: Platform.isIOS
                              ? CupertinoActivityIndicator(
                                  color: Colors.green.shade800,
                                )
                              : CircularProgressIndicator(
                                  color: Colors.green.shade800,
                                ),
                        ),
                        onImageForAnalysis: (img) => _processCameraImage(img),
                        imageAnalysisConfig: AnalysisConfig(
                          autoStart: true,
                          androidOptions: const AndroidAnalysisOptions.nv21(
                            width: 250,
                          ),
                          maxFramesPerSecond: 30,
                        ),
                        builder: (state, previewSize, previewRect) {
                          _cameraState = state;
                          return M7PreviewDecoratorWidget(
                            cameraState: state,
                            faceDetectionStream: _faceDetectionController,
                            previewSize: previewSize,
                            previewRect: previewRect,
                            detectionColor: _steps[
                                    _stepsKey.currentState?.currentIndex ?? 0]
                                .detectionColor,
                          );
                        },
                        saveConfig: SaveConfig.photo(
                          pathBuilder: () async {
                            final String fileName = "${M7Utils.generate()}.jpg";
                            final String path =
                                await getTemporaryDirectory().then(
                              (value) => value.path,
                            );
                            return "$path/$fileName";
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : M7LivelynessInfoWidget(
                onStartTap: () {
                  if (!mounted) {
                    return;
                  }
                  _startTimer();
                  setState(
                    () => _isInfoStepCompleted = true,
                  );
                },
              ),
        if (_cameraState != null)
          Align(
            alignment: Alignment(0.0, -1 / 3),
            child: CircularProgress(),
          ),
        if (_isInfoStepCompleted)
          M7LivelynessDetectionStepOverlay(
            key: _stepsKey,
            steps: _steps,
            onCompleted: () {
              // print(
              //     "${DateTime.now()}, before _takePicture faceDetector.close, alreadyOnComplete $alreadyOnComplete");
              faceDetector.close();
              if (alreadyOnComplete == false) {
                alreadyOnComplete = true;
                _takePicture(
                  didCaptureAutomatically: true,
                );
              }
            },
            hintMessage: widget.config.hintMessage,
          ),
        Visibility(
          visible: _isCaptureButtonVisible,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(
                flex: 20,
              ),
              MaterialButton(
                onPressed: () => _takePicture(
                  didCaptureAutomatically: false,
                ),
                color: widget.config.captureButtonColor ??
                    Theme.of(context).primaryColor,
                textColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.camera_alt,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 10,
              top: 10,
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: IconButton(
                onPressed: () {
                  _onDetectionCompleted(
                    imgToReturn: null,
                    didCaptureAutomatically: null,
                  );
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularProgress extends StatefulWidget {
  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // 触发重绘
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat(); // 完成后重新开始
        }
      });

    _controller.forward(); // 开始动画
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularProgressPainter(_animation.value),
      child: Container(
        width: 260,
        height: 260,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  // 背景灰色弧
  final backgroundPaint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..strokeWidth = 7.0
    ..style = PaintingStyle.stroke;

  // 前景绿色弧
  final foregroundPaint = Paint()
    ..color = Colors.green.shade800.withOpacity(0.8)
    ..strokeWidth = 7.0
    ..style = PaintingStyle.stroke;

  CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = -pi / 2; // 顶部中心开始
    final sweepAngle = 2 * pi / 5; // 弧度长度（1/5的圆）
    final progressAngle = 2 * pi * progress; // 动态的进度长度
    final offset = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) + 5; // 减去线宽，防止边缘被裁剪

    // 画背景灰色弧
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      startAngle,
      2 * pi, // 完整的圆
      false,
      backgroundPaint,
    );

    // 动态计算进度弧开始的角度
    final foregroundAngleOffset = 2 * pi * progress; // 全圆旋转
    final foregroundStartAngle =
        -pi / 2 + foregroundAngleOffset; // 从顶部中心开始，加上偏移
    // 画前景绿色进度弧
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      foregroundStartAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// class CircleBorderPainter extends CustomPainter {
//   final Animation<double> animation;
//
//   CircleBorderPainter(this.animation) : super(repaint: animation);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.white.withOpacity(1 - animation.value) // 动态改变透明度
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 5.0;
//
//     // 绘制圆圈边界动画效果
//     canvas.drawCircle(size.center(Offset.zero), size.width * 0.3 + 5.0, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
