import '../lib/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LivenessDetectionScreen(),
    );
  }
}

class LivenessDetectionScreen extends StatefulWidget {
  @override
  _LivenessDetectionScreenState createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  String imgPath = '';

  @override
  void initState() {
    super.initState();
    detectLiveness();
  }

  Future<void> detectLiveness() async {
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

    setState(() {
      imgPath = response?.imgPath ?? 'No image path available';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(imgPath),
      ),
    );
  }
}