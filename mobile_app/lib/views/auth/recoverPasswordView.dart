import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/auth/authLayout.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:flutter/material.dart';

class RecoverPasswordView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RecoverPasswordView> {
  
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }
  
  /// Validates the email.
  String? validateEmail(String value) {
    return value.contains('@') ? null : 'Introduce un correo válido.';
  }

  void recoverPassword() {

  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
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
            EcoButton(onPressed: recoverPassword, child: Text('Recuperar')).paddingOnly(t: 25),
          ],
        ),
      ),
    );
  }
}
