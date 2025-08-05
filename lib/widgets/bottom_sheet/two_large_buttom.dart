import 'package:flutter/material.dart';
// import 'dart:math' as math;
Future<bool?> twoLargeButtonBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String fillButtonText,
  required String outlineButtonText,
  required VoidCallback outlineOnPressed,
  required VoidCallback fillOnPressed,
  bool? isDismissible
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isDismissible: isDismissible??false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(75),
    builder: (context) {
      return _BouncingSheetContent(
        title: title,
        subtitle: subtitle,
        fillButtonText: fillButtonText,
        outlineButtonText: outlineButtonText,
        outlineOnPressed: outlineOnPressed,
        fillOnPressed: fillOnPressed,
      );
    },
  );
}


class _BouncingSheetContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final String fillButtonText;
  final String outlineButtonText;
  final VoidCallback outlineOnPressed;
  final VoidCallback fillOnPressed;

  const _BouncingSheetContent({
    required this.title,
    required this.subtitle,
    required this.fillButtonText,
    required this.outlineButtonText,
    required this.outlineOnPressed,
    required this.fillOnPressed,
  });

  @override
  State<_BouncingSheetContent> createState() => _BouncingSheetContentState();
}

class _BouncingSheetContentState extends State<_BouncingSheetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve:Curves.easeOutBack, // Bounce effect
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.only(right: 20,left: 20, bottom: 40),
        child: SlideTransition(
          position: _animation,
          child: Material(
            elevation: 12,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(36),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  Text(widget.subtitle),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.outlineOnPressed,
                          child: Text(widget.outlineButtonText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.fillOnPressed,
                          child: Text(widget.fillButtonText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//
// Future<bool?> TwoLargeButtonBottomSheet({
//   required BuildContext context,
//   required String title,
//   required String subtitle,
//   required String fillButtonText,
//   required String outlineButtonText,
//   required VoidCallback outlineOnPressed,
//   required VoidCallback fillOnPressed,
// }) {
//   return showModalBottomSheet<bool>(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     isDismissible: false,
//     builder: (context) => Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(subtitle,),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: outlineOnPressed,
//                   child:  Text(outlineButtonText),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: fillOnPressed,
//                   child:  Text(fillButtonText),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
