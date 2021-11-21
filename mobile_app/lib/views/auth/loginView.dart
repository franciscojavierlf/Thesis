import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/auth/authLayout.dart';
import 'package:ecotoken/views/auth/loginController.dart';
import 'package:ecotoken/views/auth/recoverPasswordView.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:ecotoken/widgets/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.loading.value
          ? SplashScreen()
          : AuthLayout(
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
                    Obx(
                      () => Text(
                        controller.message.value,
                        style: TextStyle(color: controller.success.value ? Colors.green : Colors.red),
                      ).paddingOnly(top: 10, bottom: 10),
                    ),
                    // Login
                    EcoButton(
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
            ),
    );
  }
}
