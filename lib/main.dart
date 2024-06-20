// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:firebase_core/firebase_core.dart';
import 'services/authenticate.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(), builder: AuthService().handleAuth());
  }
}

