import 'package:deltaline/pages/login_screen.dart';
import 'package:deltaline/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deltaline/services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  final ApiService apiService;

  RegistrationScreen(this.apiService);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscureText = true;
  bool _obscureText1 = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();
  String _userType = 'tenant';
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleRepasswordVisibility() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String repassword = _repasswordController.text;
    final String userType = _userType;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {
      final url = 'https://chakras.foundation/wpadmin/public/api/register';

        setState(() {
          _isLoading = true;
        });

        String? _fcm_token = await prefs.getString('fcm_token');
        final result = await widget.apiService.register(
          name, email, password, repassword, userType, _fcm_token!
        );

      if(result['status'] == 201) {

        setState(() {
          _isLoading = false;
        });

        // Store the token
        await prefs.setString('token', result['token']);
        await prefs.setString('role', result['role']);
        await prefs.setString('name', result['name']);

        // Navigate to the next page or display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(apiService: widget.apiService)),
        );
      } else {

        setState(() {
          _isLoading = false;
        });
        // Handle login error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${result["message"]}')),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Form(
          key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0), // Adjust height as needed
              Center(
                child: Container(
                  width: 250.0, // Adjust size as needed
                  height: 200.0, // Adjust size as needed
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'), // Replace with your logo image
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0), // Adjust height as needed
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Fullname',
                  hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.account_circle, color: Colors.black),
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
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fullname is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Adjust height as needed
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
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Adjust height as needed
              TextFormField(
                obscureText: _obscureText,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
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
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Adjust height as needed
              TextFormField(
                obscureText: _obscureText1,
                controller: _repasswordController,
                decoration: InputDecoration(
                  hintText: 'Re-type Password',
                  hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText1 ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _toggleRepasswordVisibility,
                  ),
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
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Adjust height as needed
              DropdownButtonFormField<String>(
                value: _userType,
                decoration: InputDecoration(
                  labelText: 'User Type',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 236, 236, 236),
                  contentPadding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236)),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236)),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                items: ['technician', 'tenant'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _userType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a user type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              Center(
                child: Container(
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
                  width: 170.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register ,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0), backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black12,
                    ),
                    child:_isLoading
                        ? SizedBox(
                            child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 236, 236, 236)),
                                )
                            ),
                          height: 15.0,
                          width: 15.0,
                        )
                        : Text(
                        'SIGN UP' ,
                        style: TextStyle(
                          color: Color.fromARGB(255, 236, 236, 236),
                          fontSize: 14.0,
                        )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0), // Adjust height as needed
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(widget.apiService)),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
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

