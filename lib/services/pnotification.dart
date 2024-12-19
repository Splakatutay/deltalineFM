import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title : ${message.notification ?.title}' );
  print('Body : ${message.notification ?.body}' );
  print('Payload : ${message.data}' );
}

class Pnotification {

    final _firebaseMessaging = FirebaseMessaging.instance;

    Future<void> initNotification() async {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final fCMToken = await _firebaseMessaging.getToken();

      print('TOKEN:  ${fCMToken}');

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a foreground message: ${message.notification?.title} ${message.notification?.body}');
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });

      // Handle background and terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked!');
      });

    }

}

