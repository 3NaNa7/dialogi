// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import '../../utils/router.dart';
import 'rooms_list.dart';
import 'widgets/home_app_bar.dart';
import '../../models/models.dart';
import '../../core/data.dart';

/// The home screen of the app
/// Contains AppBar and list of Rooms

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
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
      body: RoomsList(),
    );
  }
}
