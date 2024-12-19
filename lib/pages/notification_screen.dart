import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FirebaseMessaging _messaging;
  String _notificationMessage = "No new messages";

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // Request notification permissions (iOS only)
    _requestNotificationPermissions();

    // Get the FCM token
    _getToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notificationMessage =
        "Foreground Message: ${message.notification?.title} - ${message.notification?.body}";
      });
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        _notificationMessage =
        "App Opened Message: ${message.notification?.title} - ${message.notification?.body}";
      });
    });
  }

  // Request permissions for iOS devices
  void _requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Get the FCM token
  void _getToken() async {
    String? token = await _messaging.getToken();
    print("FCM Token: $token");
    // You can send this token to your server to send notifications to this device.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FCM Push Notifications"),
      ),
      body: Center(
        child: Text(
          _notificationMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
