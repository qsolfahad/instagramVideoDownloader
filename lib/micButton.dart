import 'package:flutter/material.dart';

class MicButton extends StatefulWidget {
  final String lang;
  final Color color;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const MicButton({
    super.key,
    required this.lang,
    required this.color,
    required this.onStart,
    required this.onStop,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.2,
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
    _controller.repeat(reverse: true);
    widget.onStart();
  }

  void _onTapUp(_) {
    _controller.stop();
    _controller.value = 1;
    widget.onStop();
  }

  void _onTapCancel() {
    _controller.stop();
    _controller.value = 1;
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _controller.value,
        child: FloatingActionButton(
          backgroundColor: widget.color,
          child: const Icon(Icons.mic, color: Colors.white),
          onPressed: () {}, // disabled, handled by gestures
        ),
      ),
    );
  }
}
