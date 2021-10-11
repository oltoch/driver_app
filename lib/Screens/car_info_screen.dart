import 'package:driver_app/FirebaseActions/save_car_info.dart';
import 'package:driver_app/Widgets/login_register_button_widget.dart';
import 'package:driver_app/Widgets/text_field_widget.dart';
import 'package:driver_app/map_config.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class CarInfoScreen extends StatelessWidget {
  static const String id = 'carInfoScreenId';

  final TextEditingController _colorTextEditingController =
      TextEditingController();

  final TextEditingController _modelTextEditingController =
      TextEditingController();

  final TextEditingController _numberTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1,
              ),
              Text(
                'Enter Car Details',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'bolt',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    TextFieldWidget(
                      controller: _modelTextEditingController,
                      label: 'Car model',
                      textInputType: TextInputType.text,
                      havePrefixIcon: false,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    TextFieldWidget(
                      controller: _numberTextEditingController,
                      label: 'License number',
                      textInputType: TextInputType.text,
                      havePrefixIcon: false,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    TextFieldWidget(
                      controller: _colorTextEditingController,
                      label: 'Color',
                      textInputType: TextInputType.text,
                      havePrefixIcon: false,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    LoginOrRegisterButton(
                      onPress: () {
                        SaveCarInfo saveInfo = SaveCarInfo(
                            context: context,
                            color: _colorTextEditingController.text,
                            model: _modelTextEditingController.text,
                            number: _numberTextEditingController.text);
                        if (saveInfo.verifyEntry()) {
                          String userId = currentFirebaseUser!.uid;
                          saveInfo.saveDriverCarInfo(userId);
                          Navigator.pushNamedAndRemoveUntil(
                              context, MainScreen.id, (route) => false);
                        }
                      },
                      text: 'Save Info',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
