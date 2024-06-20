// ignore_for_file: prefer_const_constructors
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/phone/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/loading.dart';
import '../utils/router.dart';
import '../utils/app_color.dart';

class AuthService {
  /// returns the initial screen depending on the authentication results
  handleAuth() {
    return (BuildContext context, snapshot) {
      if (snapshot.hasData) {
        return MaterialApp(
            title: 'Dialogi',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: router,
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColor.LightBrown,
                    primary: Color.fromARGB(255, 54, 61, 75))),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return HomeScreen();
                }
                return LoginScreen();
              },
            ));
      } else {
        return MaterialApp(
            title: 'Dialogi',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: router,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColor.LightBrown,
              appBarTheme: AppBarTheme(
                elevation: 0.0,
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
            ),
            home: LoadingScreen());
      }
    };
  }

  /// This method is used to logout the `FirebaseUser`
  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
