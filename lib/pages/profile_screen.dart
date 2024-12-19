import 'package:deltaline/pages/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/pages/change_password_screen.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:deltaline/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({required this.apiService, Key? key}) : super(key: key);
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {

  String? name = "";

  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async{
    // Simulate data loading
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "User";
    });
  }

  void _logout(context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('name');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen(widget.apiService)),
    );

  }

  Future<void> _deleteUser(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://admin.deltalinefm.com/api/user-delete')
      );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'DELETE';

    await request.send();
  }

  void showDeleteAccountDialog(context)  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text("Do you want to delete your account?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                // Handle account deletion
                // You can add your deletion logic here
                await _deleteUser(context);
                // Close the dialog
                Navigator.of(context).pop();

                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100.0),
                  bottomRight: Radius.circular(100.0)
              ),
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  name!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileButton(Icons.edit, "Edit Profile", 'profile', context),
                _buildProfileButton(Icons.key, "Change Password", 'pass', context),
                _buildProfileButton(Icons.delete, "Delete Account", 'delete', context),
                _buildProfileButton(Icons.logout, "Sign out", 'logout', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(IconData icon, String text, String action, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(text),
        trailing: Icon(icon, color: Colors.green),
        onTap: () {
          print(action);
          if(action == 'pass')
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen(apiService: widget.apiService,))
              );
            }
          if(action == 'profile')
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(apiService: widget.apiService,))
              );
            }

          if(action == 'logout')
            {
              _logout(context);
            }

          if(action == 'delete')
            {
              showDeleteAccountDialog(context);
            }
        },
      ),
    );
  }
}