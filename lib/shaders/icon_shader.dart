import 'package:flutter/material.dart';

class Shader extends StatelessWidget {
  final Widget child;

  const Shader({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Colors.black,
          Colors.teal,
          Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        //transform: GradientRotation(45)
      ).createShader(bounds),
      child: child,
    );
  }
}