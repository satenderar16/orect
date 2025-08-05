import 'package:flutter/material.dart';
class AnimatedFlag extends StatefulWidget {
  final String message;
  final Color color;
  final VoidCallback onDismissed;
  final Duration duration;
  final bool error;

  const AnimatedFlag({
    super.key,
    required this.message,
    required this.color,
    required this.onDismissed,
    this.duration = const Duration(seconds: 3),
    this.error = false
  });

  @override
  State<AnimatedFlag> createState() => _AnimatedFlagState();
}

class _AnimatedFlagState extends State<AnimatedFlag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Right to left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInSine,reverseCurve: Curves.easeOutSine));

    _controller.forward();

    // Auto-dismiss logic after duration
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  void _dismissImmediately() async {
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius:  BorderRadius.circular(
                  6
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.message,
                              style: TextTheme.of(context).bodyMedium!.copyWith(color: widget.error?Theme.of(context).colorScheme.onErrorContainer:Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          ),
                          IconButton(
                            icon:  Icon(Icons.close,color: widget.error?Theme.of(context).colorScheme.onErrorContainer:Theme.of(context).colorScheme.onPrimaryContainer,),
                            onPressed: _dismissImmediately,
                            padding: EdgeInsets.all(0.0),
                          ),
                        ],
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.0),
                      duration: widget.duration,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor:  widget.error?Theme.of(context).colorScheme.errorContainer:Theme.of(context).colorScheme.primaryContainer ,
                          valueColor:  AlwaysStoppedAnimation<Color>(widget.error?Theme.of(context).colorScheme.onErrorContainer:Theme.of(context).colorScheme.onPrimaryContainer),
                        );
                      },
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
