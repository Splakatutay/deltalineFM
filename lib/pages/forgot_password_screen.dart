import 'package:deltaline/pages/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final ApiService apiService;

  ForgotPasswordScreen(this.apiService);
  @override
  _ForgotPasswordScreen createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _forgotPassword() async {

    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });


      final result = await widget.apiService.forgotPassword(
        _emailController.text
      );

      setState(() {
        _isLoading = false;
      });

      if(result['status'] == 200) {
        // Navigate to the next page or display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email Successful Sent..')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerificationScreen(widget.apiService, _emailController.text)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result['message']}')),
        );
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Form(
        key: _formKey,
          child: Padding(
          padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 250.0, // Adjust size as needed
                    height: 200.0, // Adjust size as needed
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/forgot_password.png'), // Replace with your logo image
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Enter Email Address \n associated with the account.',
                    style: TextStyle(
                      fontSize: 18 ,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    'we will email you a link to reset \n your password.',
                    style: TextStyle(
                        fontSize: 14 ,
                        fontWeight: FontWeight.normal
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236))
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 130.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 178, 179, 177).withOpacity(1),
                          spreadRadius: 1,
                          blurRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _forgotPassword,
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
                          'SEND',
                          style: TextStyle(
                            color: Color.fromARGB(255, 236, 236, 236),
                            fontSize: 14.0,
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}