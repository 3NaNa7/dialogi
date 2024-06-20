// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool isLoading = false;
  Animation<double> _opacityAnimation;
  AnimationController _animationController;

  String _email;
  String _pwd;

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

  void validateAndSubmit(buildContext) async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        await auth.signInWithEmailAndPassword(
            email: _email.trim(), password: _pwd.trim());
        ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
            'Logged In successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Theme.of(buildContext).colorScheme.primary,
        ));
        Navigator.of(buildContext).pushReplacementNamed(Routers.home);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
            content: Text(
              'No user found for that email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Theme.of(buildContext).colorScheme.error,
          ));
          setState(() {
            isLoading = false;
          });
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
            content: Text(
              'Wrong password provided for that user.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Theme.of(buildContext).colorScheme.error,
          ));
          setState(() {
            isLoading = false;
          });
        }
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
              image: AssetImage('assets/images/register.png'),
              fit: BoxFit.cover)),
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
                          padding: EdgeInsets.only(left: 35, top: 110),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: Color.fromARGB(255, 253, 243, 195),
                                  size: 80,
                                ),
                                Text(
                                  'Welcome\nBack',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 248, 203, 3),
                                      fontSize: 33,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
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
                              ? _mediaQuery.size.height * 0.4
                              : _mediaQuery.size.height * 0.15,
                          right: 35,
                          left: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
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
                                  'Sign In',
                                  style: TextStyle(
                                      color: Color(0xff4c505b),
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700),
                                ),
                                isLoading
                                    ? CircularProgressIndicator()
                                    : CircleAvatar(
                                        radius: 30,
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
                              height: 30,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, Routers.register);
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xff4c505b),
                                        ),
                                      )),
                                )
                              ],
                            )
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
