import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

Future<Map<String, String>> fetchUser() async {
  Map<String, String> profileData = {
    'name': 'Anonymous',
    'username': '@anonymous',
    'profileImage': 'assets/images/profile.png',
  };

  var documentSnapshot = await FirebaseFirestore.instance
      .collection('signedUpUsers')
      .doc(auth.FirebaseAuth.instance.currentUser.uid)
      .get();

  if (documentSnapshot.exists) {
    var username = documentSnapshot.data()['username'] as String;

    if (username != null) {
      profileData = {
        'name': username[0].toUpperCase() + username.substring(1).toLowerCase(),
        'username': '@${username.toLowerCase()}',
        'profileImage': 'assets/images/profile.png',
      };

      return profileData;
    }
  }

  // Return the default profile data
  return profileData;
}

/// Data for 3 rooms in BottomSheet
List bottomSheetData = [
  {
    'image': 'assets/images/open.png',
    'text': 'Open',
    'selectedMessage': 'Start a room open to everyone',
  },
  {
    'image': 'assets/images/social.png',
    'text': 'Social',
    'selectedMessage': 'Start a room with people I follow',
  },
  {
    'image': 'assets/images/closed.png',
    'text': 'Closed',
    'selectedMessage': 'Start a room for people I choose',
  },
];
