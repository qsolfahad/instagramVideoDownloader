import 'package:flutter/material.dart';

class TypingDots extends AnimatedWidget {
  const TypingDots({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    int activeDot = animation.value.floor() % 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedOpacity(
            opacity: i == activeDot ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 300),
            child: const CircleAvatar(
              radius: 5,
              backgroundColor: Colors.black54,
            ),
          ),
        );
      }),
    );
  }
}
