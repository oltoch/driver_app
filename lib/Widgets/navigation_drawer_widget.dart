import 'package:driver_app/DataHandler/app_data.dart';
import 'package:driver_app/Screens/login_screen.dart';
import 'package:driver_app/Widgets/divider_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationDrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 255.0,
      child: Drawer(
        child: ListView(
          children: [
            Container(
              height: 165.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'images/user_icon.png',
                      height: 65.0,
                      width: 65.0,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Provider.of<AppData>(context, listen: false)
                                      .users
                                      .name !=
                                  ''
                              ? Provider.of<AppData>(context, listen: false)
                                  .users
                                  .name
                              : 'Profile Name',
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: 'bolt-semibold'),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text('Visit Profile'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            DividerWidget(),
            SizedBox(
              height: 12.0,
            ),
            ListTile(
              leading: Icon(
                Icons.history,
              ),
              title: Text(
                'History',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
              ),
              title: Text(
                'Visit Profile',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.info,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.id, (route) => false);
              },
              child: ListTile(
                leading: Icon(
                  Icons.login_outlined,
                ),
                title: Text(
                  'LogOut',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
