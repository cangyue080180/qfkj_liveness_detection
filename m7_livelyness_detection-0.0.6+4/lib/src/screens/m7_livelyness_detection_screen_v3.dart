import 'dart:async';

import 'package:m7_livelyness_detection/index.dart';
import 'package:flutter/cupertino.dart';

class M7LivelynessDetectionPageV3 extends StatelessWidget {
  final M7DetectionConfig config;

  const M7LivelynessDetectionPageV3({
    required this.config,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: M7LivelynessDetectionScreenV3(
          config: config,
        ),
      ),
    );
  }
}

class M7LivelynessDetectionScreenV3 extends StatefulWidget {
  final M7DetectionConfig config;

  const M7LivelynessDetectionScreenV3({
    required this.config,
    super.key,
  });

  @override
  State<M7LivelynessDetectionScreenV3> createState() =>
      _M7LivelynessDetectionScreenAndroidState();
}

class _M7LivelynessDetectionScreenAndroidState
    extends State<M7LivelynessDetectionScreenV3>/* with SingleTickerProviderStateMixin*/{
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
    faceDetector.close();
    super.deactivate();
  }

  @override
  void dispose() {
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
      final List<Face> detectedFaces =
      await faceDetector.processImage(inputImage);
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
        print("Test turnRight: ${face.headEulerAngleY ?? 0}");
        const double headTurnThreshold = 45.0;
        if ((face.headEulerAngleY ?? 0) > (headTurnThreshold)) {
          _startProcessing();
          await _completeStep(step: step);
        }
        break;
      case M7LivelynessStep.turnRight:
        print("Test turnRight: ${face.headEulerAngleY ?? 0}");
        const double headTurnThreshold = -45.0;
        if ((face.headEulerAngleY ?? 0) > (headTurnThreshold) &&
            (face.headEulerAngleY ?? 0) < -20.0) {
          _startProcessing();
          await _completeStep(step: step);
        }
        break;
      case M7LivelynessStep.smile:
        const double smileThreshold = 0.75;
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
    print("liming build out");
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        _isInfoStepCompleted
            ? Align(
          alignment: Alignment(0.0, -1/3),
          child: ClipOval(
            child: Container(
              width: 260,
              height: 260,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CameraAwesomeBuilder.custom(
                  flashMode: FlashMode.auto,
                  zoom: 0.1,
                  previewFit: CameraPreviewFit.fitWidth,
                  aspectRatio: CameraAspectRatios.ratio_4_3,
                  sensor: Sensors.front,
                  progressIndicator: Center(
                    child: Platform.isIOS
                        ? CupertinoActivityIndicator(color: Colors.green.shade800,)
                        : CircularProgressIndicator(color: Colors.green.shade800,),
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
                      detectionColor:
                      _steps[_stepsKey.currentState?.currentIndex ?? 0]
                          .detectionColor,
                    );
                  },
                  saveConfig: SaveConfig.photo(
                    pathBuilder: () async {
                      final String fileName = "${M7Utils.generate()}.jpg";
                      final String path = await getTemporaryDirectory().then(
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
            alignment: Alignment(0.0, -1/3),
            child: CircularProgress(),
          ),

        if (_isInfoStepCompleted)
          M7LivelynessDetectionStepOverlay(
            key: _stepsKey,
            steps: _steps,
            onCompleted: () => _takePicture(
              didCaptureAutomatically: true,
            ),
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

