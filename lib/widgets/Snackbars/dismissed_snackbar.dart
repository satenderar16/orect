

import 'package:amtnew/main.dart';
import 'package:flutter/material.dart';

void showSingleSnackBar({required String message, Duration? duration, String? label,SnackBarBehavior? behavior,VoidCallback? onPressed,bool isAction=true}) {
  final messenger = scaffoldMessengerKey.currentState;

  messenger?.hideCurrentSnackBar();

  messenger?.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration ?? const Duration(seconds: 3), // auto-dismiss after 3 seconds
      action:isAction? SnackBarAction(
        label: label ??'DISMISS',
        onPressed:onPressed ?? () {
          messenger.hideCurrentSnackBar(); // explicitly hide when user taps dismiss
        },
      ):null,
      behavior: behavior ?? SnackBarBehavior.floating,
    ),
  );
}