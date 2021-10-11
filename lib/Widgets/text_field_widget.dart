import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? textInputType;
  final bool? obscureText;
  final bool havePrefixIcon;
  final IconData? prefixIcon;

  TextFieldWidget({
    required this.controller,
    required this.label,
    this.textInputType,
    this.obscureText,
    required this.havePrefixIcon,
    this.prefixIcon,
  });

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscure = false;
  bool _isObscure() {
    //if obscureText value passed in is null or false,
    // return false otherwise, return true
    return widget.obscureText == null || widget.obscureText == false ? false : true;
  }

  InputDecoration inputDecorationWithSuffixIcon() {
    return InputDecoration(
      prefixIcon: widget.havePrefixIcon
          ? Icon(
              widget.prefixIcon,
            )
          : null,
      suffixIcon: IconButton(
        icon: Icon(!_obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      ),
      labelText: widget.label,
      labelStyle: TextStyle(fontSize: 14),
      hintStyle: TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }

  InputDecoration inputDecorationWithoutSuffixIcon() {
    return InputDecoration(
      prefixIcon: widget.havePrefixIcon
          ? Icon(
              widget.prefixIcon,
            )
          : null,
      labelText: widget.label,
      labelStyle: TextStyle(fontSize: 14),
      hintStyle: TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      /*onChanged: (value){
        String holder = value;
      },*/
      controller: widget.controller,
      obscureText: widget.obscureText == null || false ? false : _obscure,
      keyboardType: widget.textInputType,
      decoration: _isObscure()
          ? inputDecorationWithSuffixIcon()
          : inputDecorationWithoutSuffixIcon(),
      style: TextStyle(
        fontSize: 14,
      ),
    );
  }

  @override
  void initState() {
    _obscure = _isObscure();
    super.initState();
  }
}
