import 'package:deltaline/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deltaline/pages/main_screen.dart';

class SplashScreen extends StatefulWidget {
  final ApiService apiService;

  SplashScreen(this.apiService);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasToken = false;


  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Navigate to home if token is found, otherwise go to login
    if (token != null && token.isNotEmpty) {
      setState(() {
        _hasToken = true;
      });
    }
    _navigateToHome();

  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 6), () {});

    if(_hasToken)
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(apiService: widget.apiService)),
        );
      } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(widget.apiService)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[

          Center(
            child: Image.asset(
              'assets/images/splash_screen.gif',
              width: 500, // Adjust the width as needed
              height: 500, // Adjust the height as needed
            ),
          ),
        ],
      ),
    );
  }
}
