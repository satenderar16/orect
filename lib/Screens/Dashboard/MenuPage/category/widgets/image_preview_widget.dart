import 'package:flutter/material.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullscreenImageViewer({required this.imageUrl, super.key});

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final ValueNotifier<double> _dragOffset = ValueNotifier(0.0);
  bool _isDragging = false;

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragOffset.value += details.delta.dy;
    _isDragging = true;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset.value > 100) {
      Navigator.of(context).pop();
    } else {
      _dragOffset.value = 0.0;
      _isDragging = false;
    }
  }

  @override
  void dispose() {
    _dragOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: ValueListenableBuilder<double>(
          valueListenable: _dragOffset,
          builder: (context, offset, child) {
            final int opacity = (255 - offset).clamp(0, 200).toInt();
            return Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.scrim.withAlpha(opacity),
                ),
                Center(
                  child: Transform.translate(
                    offset: Offset(0, offset),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        (offset/20 ).clamp(0.0, 20.0),
                      ),
                      child: Hero(
                        tag: widget.imageUrl,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                // Close Button

              ],
            );
          },
        ),
      ),
    );
  }
}
