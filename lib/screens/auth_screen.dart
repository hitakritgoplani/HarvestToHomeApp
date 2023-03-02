import 'dart:async';
import 'dart:ui' as ui;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:harvesttohome/models/KeyboardVisibilityBuilder.dart';
import 'package:harvesttohome/shaders/icon_shader.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

enum AuthMode {
  login,
  signIn,
}

class AuthScreen extends StatefulWidget {
  static const routeName = '/AuthScreen';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation = Tween<double>(begin: 1, end: 0.65).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              CustomPaint(
                painter: CurvePainter(height: height, width: width),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 100, left: 20),
                  child: Shader(
                    type: 1,
                    child: AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TyperAnimatedText(
                          'HARVEST2HOME',
                          speed: const Duration(milliseconds: 100),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Comfortaa',
                            fontSize: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              KeyboardVisibilityBuilder(
                child: SizedBox(
                  height: height,
                  width: width,
                ),
                builder: (ctx, child, isVisible){
                  if(isVisible){
                    return BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaY: 8.0,
                        sigmaX: 8.0,
                      ),
                      child: child,
                    );
                  } else {
                    return child;
                  }
                },
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: LoginWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  AuthMode _authMode = AuthMode.login;

  final Map<String, String> _authData = {
    'username': '',
    'password': '',
  };

  bool _isLoading = false;

  OutlineInputBorder drawBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }

  InputDecoration inputDecoration(String text) {
    return InputDecoration(
      labelText: text,
      filled: true,
      fillColor: const Color.fromRGBO(232, 236, 242, 1),
      floatingLabelStyle: const TextStyle(color: Color.fromRGBO(48, 55, 51, 1)),
      labelStyle: const TextStyle(color: Color.fromRGBO(48, 55, 51, 1)),
      contentPadding: const EdgeInsets.all(25),
      enabledBorder: drawBorder(const Color.fromRGBO(232, 236, 242, 1)),
      focusedBorder: drawBorder(const Color.fromRGBO(36, 94, 52, 1)),
      errorBorder: drawBorder(Colors.red),
      focusedErrorBorder: drawBorder(Colors.red),
      prefixIcon: text == 'Password'
          ? const Icon(Icons.lock)
          : const Icon(Icons.person),
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.login) {
      await Provider.of<Auth>(context, listen: false)
          .signIn(
            _authData['username']!,
            _authData['password']!,
          )
          .then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged In Successfully!'),
                duration: Duration(seconds: 1),
              ),
            ),
          )
          .catchError(
            (onError) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed. $onError'),
                duration: const Duration(seconds: 1),
              ),
            ),
          );
    } else {
      await Provider.of<Auth>(context, listen: false)
          .signUp(
            _authData['username']!,
            _authData['password']!,
          )
          .then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed In Successfully!'),
                duration: Duration(seconds: 1),
              ),
            ),
          )
          .catchError(
            (onError) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Signed In Failed. $onError'),
                duration: const Duration(seconds: 1),
              ),
            ),
          );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            KeyboardVisibilityBuilder(
              builder: (ctx, child, isVisible){
                if (!isVisible){
                  return child;
                } else {
                  return const SizedBox();
                }
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromRGBO(232, 236, 242, 1),
                radius: MediaQuery.of(context).viewInsets.vertical > 0 ? 0 : width * 0.15,
                child: const Shader(
                  type: 0,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                  ),
                ),
              ),
            ),
            SizedBox(
                height: height * (_authMode == AuthMode.login ? 0.08 : 0.025)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _authMode == AuthMode.login
                    ? "Welcome Back"
                    : "Create your account",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: height * 0.04),
            TextFormField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _usernameController,
              cursorColor: Colors.black,
              decoration: inputDecoration('Username / Email'),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || !EmailValidator.validate(value)) {
                  return 'Invalid Email ID';
                }
                return null;
              },
              onSaved: (value) {
                _authData['username'] = value!;
              },
            ),
            SizedBox(height: height * 0.02),
            TextFormField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _passwordController,
              cursorColor: Colors.white,
              obscureText: true,
              decoration: inputDecoration('Password'),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password should have at least 6 characters.';
                }
                return null;
              },
              onSaved: (value) {
                _authData['password'] = value!;
              },
            ),
            SizedBox(height: height * 0.02),
            if (_authMode == AuthMode.signIn)
              FadeTransition(
                opacity: _fadeAnimation,
                child: TextFormField(
                  enabled: _authMode == AuthMode.signIn,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  obscureText: true,
                  decoration: inputDecoration('Confirm Password'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value != _passwordController.text) {
                      return 'Passwords don\'t match.';
                    }
                    return null;
                  },
                ),
              ),
            SizedBox(height: height * 0.02),
            Stack(
              alignment: Alignment.center,
              children: [
                Shader(
                  type: 0,
                  child: Container(
                    width: width,
                    height: height * 0.07,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    await submit();
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _authMode == AuthMode.login ? 'SIGN IN' : 'REGISTER',
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            TextButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                setState(() {
                  if (_authMode == AuthMode.login) {
                    _authMode = AuthMode.signIn;
                    Timer(
                      const Duration(milliseconds: 300),
                      () => _animationController.forward(),
                    );
                  } else {
                    _authMode = AuthMode.login;
                    _animationController.reverse();
                  }
                });
              },
              child: Text(
                _authMode == AuthMode.login
                    ? 'New User? Sign up'
                    : 'Already a user? Login',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double height;
  final double width;

  const CurvePainter({required this.height, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.shader =
        ui.Gradient.linear(const Offset(0, 0), Offset(width, 0), <Color>[
      const Color.fromRGBO(116, 212, 126, 1),
      const Color.fromRGBO(65, 161, 71, 1),
      const Color.fromRGBO(27, 123, 31, 1),
    ], [
      0.0,
      0.7,
      1,
    ]);

    var path = Path();

    path.moveTo(0, height * 0.36);
    path.quadraticBezierTo(width / 7, height / 4, width / 2, height * 0.25);
    path.lineTo(width / 2, 0);
    path.lineTo(0, 0);

    path.moveTo(width / 2, height * 0.25);
    path.quadraticBezierTo(width, height / 4, width, height * 0.16);
    path.lineTo(width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);

    var tracerPaint = Paint()
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = 0.5
      ..color = const Color.fromRGBO(116, 212, 126, 1)
      ..style = PaintingStyle.stroke;

    var tracerPath = Path();
    tracerPath.moveTo(0, height * 0.1);
    tracerPath.quadraticBezierTo(width, height / 8, width, 0);

    tracerPath.moveTo(0, height * 0.2);
    tracerPath.quadraticBezierTo(width, height / 4, width, 0);

    canvas.drawPath(tracerPath, tracerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
