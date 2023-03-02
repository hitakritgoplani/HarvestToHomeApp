import 'package:flutter/material.dart';

class Shader extends StatelessWidget {
  final Widget child;
  final int type;

  const Shader({Key? key, required this.child, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const colors_0 = [
      Color.fromRGBO(116, 212, 126, 1),
      Color.fromRGBO(65, 161, 71, 1),
      Color.fromRGBO(27, 123, 31, 1),
    ];

    const colors_1 = [
      Colors.white,
      Color.fromRGBO(156, 212, 126, 1),
      Color.fromRGBO(85, 161, 71, 1),
    ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: type == 0 ? colors_0 : colors_1,
        stops: const [
          0.3,
          0.7,
          1,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        //transform: GradientRotation(45)
      ).createShader(bounds),
      child: child,
    );
  }
}
