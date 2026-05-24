import 'package:flutter/cupertino.dart';
import 'package:autofinder/views/add_workshop/steps/step_identity.dart';
import 'package:autofinder/views/add_workshop/steps/step_services.dart';
import 'package:autofinder/views/add_workshop/steps/step_location.dart';
import 'package:autofinder/views/add_workshop/steps/step_uptime.dart';
import 'package:autofinder/views/add_workshop/steps/step_verify.dart';

class WorkshopStepHelper {
  static String getStepName(int index) {
    switch (index) {
      case 0:
        return 'IDENTITY';
      case 1:
        return 'SERVICES';
      case 2:
        return 'LOCATION';
      case 3:
        return 'UPTIME';
      case 4:
        return 'VERIFY';
      default:
        return '';
    }
  }

  static Widget getStepWidget(int index) {
    switch (index) {
      case 0:
        return const StepIdentity();
      case 1:
        return const StepServices();
      case 2:
        return const StepLocation();
      case 3:
        return const StepUptime();
      case 4:
        return const StepVerify();
      default:
        return const SizedBox.shrink();
    }
  }
}
