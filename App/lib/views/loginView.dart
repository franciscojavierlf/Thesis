import 'package:ecotoken/controllers/loginViewController.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/recoverPasswordView.dart';
import 'package:ecotoken/widgets/auth/authLayout.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  final controller = Get.put(LoginViewController());

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            AuthInput(
              icon: Icon(Icons.email_outlined, color: Palette.D),
              controller: controller.emailController,
              validator: (value) => controller.validateEmail(value!),
              hintText: 'Introduce tu correo',
            ),
            SizedBox(height: 20),
            AuthInput(
              icon: Icon(Icons.lock_outline, color: Palette.D),
              controller: controller.passwordController,
              hintText: 'Introduce tu contraseña',
              obscureText: true,
            ),
            // Messages
            Obx(() => Text(controller.message.value)),
            SizedBox(height: 40),
            // Login
            CustomButton(
              onPressed: controller.tryLogin,
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 10),
            // Forgot password
            TextButton(
              onPressed: () => Get.to(RecoverPasswordView()),
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
