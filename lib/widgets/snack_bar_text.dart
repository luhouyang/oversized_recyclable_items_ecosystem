import 'package:flutter/material.dart';

class SnackBarText {
  void showBanner({required String msg, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: Text(
          msg,
        ),
      ),
    );
  }
}
