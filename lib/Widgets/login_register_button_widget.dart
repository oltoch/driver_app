import 'package:flutter/material.dart';

class LoginOrRegisterButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;

  LoginOrRegisterButton({required this.onPress, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: Center(
            child: Text(
          text,
          style: TextStyle(fontSize: 18, fontFamily: 'bolt'),
        )),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
