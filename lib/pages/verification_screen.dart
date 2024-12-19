import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:deltaline/pages/reset_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  final ApiService apiService;
  final String email;

  VerificationScreen(this.apiService, this.email);
  @override
  _VerificationScreen createState() => _VerificationScreen();
}

class _VerificationScreen extends State<VerificationScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isLoading1 = false;


  void _sendCode() async {

    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      final result = await widget.apiService.sendCode(
          _codeController.text , widget.email
      );

      setState(() {
        _isLoading = false;
      });

      if(result['status'] == 200) {
        // Navigate to the next page or display success message
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(apiService: widget.apiService, code: _codeController.text, email: widget.email)),
        );
      } else {
        // Handle login error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result['message']}')),
        );
      }
    }

  }

  void _forgotPassword(context) async {

    setState(() {
      _isLoading = true;
    });

    final result = await widget.apiService.forgotPassword(
        widget.email
    );

    setState(() {
      _isLoading = false;
    });

    if(result['status'] == 200) {
      // Navigate to the next page or display success message
      _showPopUpMessage(context, 'Code Sent to your Email.');
    } else {
      _showPopUpMessage(context, 'Failed to send email.');
    }

  }

  void _showPopUpMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dialog from closing when tapping outside
      builder: (BuildContext context) {

        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the dialog
        });

        return Dialog(
          backgroundColor: Colors.black, // Transparent background
          child: Container(
            color: Colors.black.withOpacity(1.0), // Gray background with opacity
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  Text("${message}",
                      style: TextStyle(
                        color: Color.fromARGB(255, 236, 236, 236),
                        fontSize: 16.0,
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Form(
        key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: const Text(
                        'Enter the 6-digit code sent to your email.',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
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
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Code is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                          onPressed: _isLoading ? null : _sendCode,
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
                              'Verify',
                              style: TextStyle(
                                color: Color.fromARGB(255, 236, 236, 236),
                                fontSize: 14.0,
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "If you didn't receive a code",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _forgotPassword(context);
                            },
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
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