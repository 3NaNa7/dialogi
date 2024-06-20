// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../utils/router.dart';
import '../core/data.dart';
import '../models/models.dart';
import 'home/widgets/home_app_bar.dart';

/// The home screen of the app
/// Contains AppBar and list of Rooms

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
            future: fetchUser(),
            builder: (context, snapshot) {
              return snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done
                  ? HomeAppBar(
                      profile: User.fromJson(snapshot.data),
                      onProfileTab: () {
                        Navigator.of(context).pushNamed(Routers.profile,
                            arguments: User.fromJson(snapshot.data));
                      },
                    )
                  : CircularProgressIndicator();
            }),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text(
                'LOADING...',
                style: TextStyle(color: Color.fromARGB(255, 74, 91, 99)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
