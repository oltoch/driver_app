import 'package:driver_app/DataHandler/app_data.dart';
import 'package:driver_app/Screens/car_info_screen.dart';
import 'package:driver_app/Screens/login_screen.dart';
import 'package:driver_app/Screens/main_screen.dart';
import 'package:driver_app/Screens/registration_screen.dart';
import 'package:driver_app/Services/location_class.dart';
import 'package:driver_app/map_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //currentFirebaseUser = FirebaseAuth.instance.currentUser;
  await GetLocation.getCurrentLocation();
  runApp(MyApp());
}

const String path = 'drivers';
const String ridePath = 'newRide';

DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child(path);

DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child(path)
    .child(currentFirebaseUser!.uid)
    .child(ridePath);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Driver App',
        theme: ThemeData(
          fontFamily: 'bolt semibold',
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.id
            : MainScreen.id,
        routes: {
          MainScreen.id: (context) => MainScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          CarInfoScreen.id: (context) => CarInfoScreen(),
        },
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
      ),
    );
  }
}
