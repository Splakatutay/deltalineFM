import 'package:deltaline/pages/create_service_request_screen.dart';
import 'package:deltaline/pages/profile_screen.dart';
import 'package:deltaline/pages/service_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({required this.apiService, Key? key}) : super(key: key);
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String? name = "";
  String? role = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Simulate data loading
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "User";
      role = prefs.getString('role') ?? "Role";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100.0),
                    bottomRight: Radius.circular(100.0)),
                gradient: LinearGradient(
                  colors: [Colors.green, Color(0xFF6D927A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: role == 'tenant'
                    ? <Widget>[
                  _buildGridItem('My Requests', Icons.request_page, context, 'a', widget.apiService),
                  _buildGridItem('Create Request', Icons.create, context, 'b', widget.apiService),
                  _buildGridItem('My Profile', Icons.person, context, 'c', widget.apiService),
                ]
                    : <Widget>[
                  _buildGridItem('Assigned \nRequests', Icons.request_page, context, 'a', widget.apiService),
                  _buildGridItem('My Profile', Icons.person, context, 'c', widget.apiService),
                  _buildGridItem('My Notifications', Icons.notifications, context, 'd', widget.apiService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildStatusColumn(String title, String count) {
    return Column(
      children: <Widget>[
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Card _buildGridItem(String title, IconData icon, BuildContext context, String screen, ApiService apiService) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: GestureDetector(
        onTap: () {
          if (screen == 'a') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ServiceRequestScreen(apiService: apiService)),
            );
          }
          if (screen == 'b') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateServiceRequestScreen(apiService: widget.apiService)),
            );
          }
          if (screen == 'c') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(apiService: apiService)),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 10),
            // New Buttons
            ElevatedButton(
              onPressed: () {
                // Direct Message Now action
              },
              child: const Text("Direct Message Now"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Button color
                onPrimary: Colors.white, // Text color
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Text Now action
              },
              child: const Text("Text Now"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Email Now action
              },
              child: const Text("Email Now"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
