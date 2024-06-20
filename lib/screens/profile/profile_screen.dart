// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../utils/router.dart';
import '../../models/models.dart';
import '../../services/authenticate.dart';
import '../../core/data.dart';
import '../../widgets/rounded_image.dart';

/// Contain information about current user profile

class ProfileScreen extends StatefulWidget {
  final User profile;

  const ProfileScreen({Key key, this.profile}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool bioActivated = false;
  TextEditingController biocontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 25),
        ),
        actions: [
          // Button that logout user
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routers.login, (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            profileBody(),
          ],
        ),
      ),
    );
  }

  Widget profileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedImage(
            path: widget.profile.profileImage,
            width: 100,
            height: 100,
            borderRadius: 35),
        SizedBox(height: 20),
        Text(
          widget.profile.name,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.profile.username,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TextButton(
            child: bioActivated
                ? Column(
                    children: [
                      TextFormField(
                        controller: biocontroller,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              bioActivated = false;
                            });
                          },
                          child: Text('Save'))
                    ],
                  )
                : biocontroller.text == ''
                    ? Text(
                        'Say something about yourself',
                        style: TextStyle(color: Colors.blue),
                      )
                    : Text(biocontroller.text),
            onPressed: () {
              setState(() {
                bioActivated = true;
              });
            },
          ),
        ),
      ],
    );
  }
}
