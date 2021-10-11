import 'package:driver_app/Widgets/progress_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterWithEmailAndPassword {
  final String email, password, phone, name;
  final BuildContext context;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RegisterWithEmailAndPassword(
      {required this.context,
      required this.email,
      required this.password,
      required this.name,
      required this.phone});

  Future<User?> registerNewUser() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Creating account, please wait...',
          );
        },
        barrierDismissible: false);

    try {
      final User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      return user;
    } catch (e) {
      Navigator.pop(context);
      print('Error' + e.toString());
      EasyLoading.showError('Error: ' + e.toString());
    }
  }

  bool verifyEntry() {
    if (!EmailValidator.validate(email)) {
      EasyLoading.showError('Enter a valid email address');
      return false;
    } else if (password.length < 6) {
      EasyLoading.showError('Password must be at least 6 characters');
      return false;
    } else if (name.length < 5) {
      EasyLoading.showError('Enter a valid name');
      return false;
    } else if (phone.length != 11) {
      EasyLoading.showError('Enter a valid phone number');
      return false;
    } else {
      return true;
    }
  }

  Map userDataMap() {
    Map userData = {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
    };
    return userData;
  }
}
