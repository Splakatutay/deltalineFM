import 'package:deltaline/pages/forgot_password_screen.dart';
import 'package:deltaline/pages/main_screen.dart';
import 'package:deltaline/pages/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deltaline/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;

  LoginScreen(this.apiService);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _login() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      String? _fcm_token = await prefs.getString('fcm_token');
      final result = await widget.apiService.login(
        _emailController.text,
        _passwordController.text,
        _fcm_token!
      );

      if(result['status'] == 200) {
        setState(() {
          _isLoading = false;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        await prefs.setString('role', result['role']);
        await prefs.setString('name', result['name']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User Login Successfully..')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainScreen(apiService: widget.apiService)),
        );

      } else {

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${result["message"]}')),
        );
      }

    }

  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(40.0),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const SizedBox(height: 100.0),
                  Center(
                    child: Container(
                      width: 250.0, // Adjust size as needed
                      height: 200.0, // Adjust size as needed
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          // Replace with your logo image
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                      prefixIcon: const Icon(Icons.email, color: Colors.black),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(color: Color.fromARGB(
                              255, 236, 236, 236))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(
                              color: Colors.lightGreen
                          )
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 236, 236, 236),
                      contentPadding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  // Password field
                  TextFormField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                      prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons
                              .visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(color: Color.fromARGB(
                              255, 236, 236, 236)),
                          gapPadding: 4.0
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(
                              color: Colors.lightGreen
                          )
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 236, 236, 236),
                      contentPadding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Forgot password text
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(widget.apiService)),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Login button
                  Center(
                    child: Container(
                      width: 170.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 178, 179, 177)
                                .withOpacity(1),
                            spreadRadius: 1,
                            blurRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 10,
                          shadowColor: Colors.black12,
                        ),
                        child: _isLoading
                            ? SizedBox(
                          child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 236, 236, 236)),
                              )
                          ),
                          height: 15.0,
                          width: 15.0,
                        )
                            : Text(
                            'LOG IN',
                            style: TextStyle(
                              color: Color.fromARGB(255, 236, 236, 236),
                              fontSize: 14.0,
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => RegistrationScreen(widget.apiService)),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

      );
    }

}