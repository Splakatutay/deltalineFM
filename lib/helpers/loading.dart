import 'package:flutter/material.dart';

class Loading {
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            color: Colors.black54, // Gray background with transparency
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
