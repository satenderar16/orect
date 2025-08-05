import 'package:flutter/material.dart';

class AppButtonStyles {
  // static ButtonStyle elevatedSecondary(BuildContext context) {
  //   return ElevatedButton.styleFrom(
  //     foregroundColor: Theme.of(context).colorScheme.onSecondary,
  //     backgroundColor: Theme.of(context).colorScheme.secondary,
  //   );
  // }


  static ButtonStyle outlinedSecondary(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.secondary,
      side: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
