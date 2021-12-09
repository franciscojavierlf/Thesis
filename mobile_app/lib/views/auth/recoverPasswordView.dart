import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/auth/authLayout.dart';
import 'package:ecotoken/views/auth/recoverPasswordController.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecoverPasswordView extends StatelessWidget {
  final controller = Get.put(RecoverPasswordController());

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
            EcoButton(onPressed: controller.recoverPassword, child: Text('Recuperar')).paddingOnly(top: 25),
          ],
        ),
      ),
    );
  }
}