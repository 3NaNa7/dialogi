// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen();

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;

  String _email;
  String _username;
  String _pwd;
  Animation<double> _opacityAnimation;
  AnimationController _animationController;

  void validateAndSubmit(buildContext) async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential _userCredential =
            await auth.createUserWithEmailAndPassword(
                email: _email.trim(), password: _pwd.trim());
        await FirebaseFirestore.instance
            .collection('signedUpUsers')
            .doc(_userCredential.user.uid)
            .set({'username': _username, 'email': _email});

        ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
            'Signed up successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Theme.of(buildContext).colorScheme.primary,
        ));
        Navigator.of(buildContext).pushReplacementNamed(Routers.home);
      } on FirebaseAuthException catch (err) {
        var message = 'Authentication failed. Please check credentials';
        if (err.message != null) message = err.message;

        ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(message),
          duration: Duration(seconds: 5),
          backgroundColor: Theme.of(buildContext).colorScheme.error,
        ));
        setState(() {
          isLoading = false;
        });
      } catch (err) {
        ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(err.toString()),
          duration: Duration(seconds: 1),
          backgroundColor: Theme.of(buildContext).colorScheme.error,
        ));
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    final _insetsBottom = _mediaQuery.viewInsets.bottom;
    final _deviceHeight = _mediaQuery.size.height;

    if (_insetsBottom <= 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/login.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: _insetsBottom <= 0
              ? const EdgeInsets.only(top: 30.0)
              : const EdgeInsets.only(top: 0.0), // changed from 90 to 0
          child: AnimatedContainer(
            duration: Duration(milliseconds: 700),
            curve: Curves.easeIn,
            height: _insetsBottom > 0
                ? _deviceHeight - _insetsBottom
                : _deviceHeight - 20,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 700),
                    constraints:
                        BoxConstraints(maxHeight: _insetsBottom <= 0 ? 206 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 35, top: 110), // on emulator it is 160
                          child: Row(
                            children: [
                              Text(
                                'Welcome',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 25, top: 5),
                                child: Icon(
                                  Icons.mic,
                                  color: Color.fromARGB(255, 218, 215, 205),
                                  size: 65,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      padding: EdgeInsets.only(
                          top: _insetsBottom <= 0
                              ? _mediaQuery.size.height *
                                  0.35 // 0.45 on emulator
                              : _mediaQuery.size.height * 0.15,
                          right: 35,
                          left: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: ValueKey(2),
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade300,
                                  filled: true,
                                  hintText: 'Username',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onSaved: (value) =>
                                  _username = value ?? 'Anonymous',
                              validator: (value) {
                                if (value.contains(RegExp('[0-9]'))) {
                                  return 'username must contain only letters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              key: ValueKey(1),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Email',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onSaved: (value) => _email = value,
                              validator: (value) {
                                if (!value.contains('@') || value.isEmpty) {
                                  return 'Valid email is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              key: ValueKey(3),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onSaved: (value) => _pwd = value,
                              validator: (value) {
                                if (value.length < 7) {
                                  return 'At least 7 characters required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Color(0xff4c505b),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900),
                                ),
                                isLoading
                                    ? CircularProgressIndicator()
                                    : CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Color(0xff4c505b),
                                        child: IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            validateAndSubmit(context);
                                          },
                                          icon: Icon(Icons.arrow_forward),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Have an Account?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff4c505b),
                                      ),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routers.login);
                                    },
                                    child: Text(
                                      'Sign in',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff4c505b),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
