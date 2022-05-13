import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/auth/authLayout.dart';
import 'package:ecotoken/views/auth/recoverPasswordView.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:ecotoken/widgets/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LoginView> {
  late final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var message = '';
  var loading = false;
  var success = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  /// Validates the email.
  String? validateEmail(String value) {
    return value.contains('@') ? null : 'Introduce un correo válido.';
  }

  /// Tries to login.
  void tryLogin() async {
    if (formKey.currentState!.validate()) {
      try {
        setState(() => loading = true);
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        message = '¡Inicio de sesión logrado!';
        setState(() {
          loading = false;
          success = true;
        });
      } on FirebaseAuthException catch (err) {
        print(err);
        setState(() {
          loading = false;
          message = err.message ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SplashScreen()
        : AuthLayout(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  AuthInput(
                    icon: Icon(Icons.email_outlined, color: Palette.D),
                    controller: emailController,
                    validator: (value) => validateEmail(value!),
                    hintText: 'Introduce tu correo',
                  ),
                  SizedBox(height: 20),
                  AuthInput(
                    icon: Icon(Icons.lock_outline, color: Palette.D),
                    controller: passwordController,
                    hintText: 'Introduce tu contraseña',
                    obscureText: true,
                  ),
                  // Messages
                  Text(
                    message,
                    style:
                        TextStyle(color: success ? Colors.green : Colors.red),
                  ).paddingOnly(t: 10, b: 10),

                  // Login
                  EcoButton(
                    onPressed: tryLogin,
                    child: Text('Iniciar Sesión'),
                  ),
                  SizedBox(height: 10),
                  // Forgot password
                  TextButton(
                    onPressed: () => goto(context, RecoverPasswordView()),
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.D,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
