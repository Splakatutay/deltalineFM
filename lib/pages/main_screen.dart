import 'package:deltaline/pages/service_request_screen.dart';
import 'package:deltaline/pages/profile_screen.dart';
import 'package:deltaline/pages/home_screen.dart';
import 'package:deltaline/pages/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:deltaline/services/api_service.dart';

class MainScreen extends StatefulWidget {
  final ApiService apiService;

  const MainScreen({required this.apiService, Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [];

  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(apiService: widget.apiService),
      ServiceRequestScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _updateIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.request_page),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
              selectedItemColor: Colors.green
          ),
        ),
      );
  }
}
