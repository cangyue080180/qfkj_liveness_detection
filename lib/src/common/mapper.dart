

import 'package:m7_livelyness_detection/index.dart';

import '../vo/detection_threshold.dart';
import '../vo/livelyness_step.dart';
import '../vo/livelyness_step_item.dart';

class Mapper {
  static List<M7DetectionThreshold> mapToM7Threshold(List<DetectionThreshold> thresholds) {
    return thresholds.map((e) {
      if (e is SmileDetectionThreshold) {
        return M7SmileDetectionThreshold(probability: e.probability);
      } else if(e is BlinkDetectionThreshold){
        return M7BlinkDetectionThreshold(leftEyeProbability: e.leftEyeProbability,
            rightEyeProbability: e.rightEyeProbability);
      } else {
        return M7HeadTurnDetectionThreshold(rotationAngle:  (e as HeadTurnDetectionThreshold).rotationAngle);
      }
    }).toList();
  }

  static List<M7LivelynessStepItem> mapToM7StepItem(List<LivelynessStepItem> steps) {
    return steps.map((e) => M7LivelynessStepItem(step: mapToStep(e.step), title: e.title, isCompleted: e.isCompleted, thresholdToCheck: e.thresholdToCheck, detectionColor: e.detectionColor)).toList();
  }

  static M7LivelynessStep mapToStep(LivelynessStep step) {
    if (step == LivelynessStep.blink) {
      return M7LivelynessStep.blink;
    } else if (step == LivelynessStep.smile) {
      return M7LivelynessStep.smile;
    }else if (step == LivelynessStep.turnLeft) {
      return M7LivelynessStep.turnLeft;
    } else {
      return M7LivelynessStep.turnRight;
    }
  }
}