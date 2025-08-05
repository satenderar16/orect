
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool?> exitAlertDialog(context) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
      title: const Text('Exit App?'),
      content: const Text('Do you really want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () =>context.pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: const Text('Exit'),
        ),
      ],
    ),
  );
}