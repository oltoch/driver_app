import 'package:driver_app/Widgets/progress_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginWithEmailAndPassword {
  final BuildContext context;
  final String email, password;
  final _firebaseAuth = FirebaseAuth.instance;
  LoginWithEmailAndPassword(
      {required this.context, required this.email, required this.password});

  Future<User?> loginUser() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Logging in, please wait...',
          );
        },
        barrierDismissible: false);

    try {
      final User? user = (await _firebaseAuth.signInWithEmailAndPassword(
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
    } else if (password.isEmpty) {
      EasyLoading.showError('Password field cannot be empty');
      return false;
    } else {
      return true;
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
