
import 'package:flutter/cupertino.dart';

class AnimatedSizeContainer extends StatefulWidget {
  final Widget child;
  final Curve curve;
  final Duration duration;

  const AnimatedSizeContainer({super.key, required this.child,this.curve = Curves.fastOutSlowIn,this.duration =const Duration(milliseconds: 300)});

  @override
  State<AnimatedSizeContainer> createState() => _AnimatedSizeContainerState();
}

class _AnimatedSizeContainerState extends State<AnimatedSizeContainer> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration ,
      curve: widget.curve,
      child: IntrinsicHeight(child: widget.child),
    );
  }
}