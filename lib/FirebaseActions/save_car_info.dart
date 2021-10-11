import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveCarInfo {
  final String color, model, number;
  final BuildContext context;

  SaveCarInfo(
      {required this.context,
      required this.color,
      required this.model,
      required this.number});

  void saveDriverCarInfo(String userId) {
    driversRef.child(userId).child('car_details').set(userDataMap());
  }

  bool verifyEntry() {
    if (color.length < 3) {
      EasyLoading.showError('Enter a valid color here');
      return false;
    } else if (model.isEmpty) {
      EasyLoading.showError('Enter a model for your car');
      return false;
    } else if (number.length != 8 && number.length != 7) {
      //if (!(number.length() == 8 ^ number.length() == 7))
      //if ((number.length() == 8) == (number.length() == 7))
      EasyLoading.showError('Enter a valid license number');
      return false;
    } else {
      return true;
    }
  }

  Map userDataMap() {
    Map carInfo = {
      'name': color.trim(),
      'email': model.trim(),
      'phone': number.trim(),
    };
    return carInfo;
  }
}
