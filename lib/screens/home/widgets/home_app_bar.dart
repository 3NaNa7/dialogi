// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/rounded_image.dart';

class HomeAppBar extends StatelessWidget {
  final User profile;
  final Function onProfileTab;

  const HomeAppBar({Key key, this.profile, this.onProfileTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Rooms', style: TextStyle(fontSize: 25)),
        GestureDetector(
          onTap: onProfileTab,
          child: Column(
            children: [
              RoundedImage(
                path: profile.profileImage,
                width: 40,
                height: 40,
              ),
              Text(
                profile.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
