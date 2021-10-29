import 'package:ecotoken/controllers/loginViewController.dart';
import 'package:ecotoken/controllers/recoverPasswordViewController.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/auth/authLayout.dart';
import 'package:ecotoken/widgets/authInput.dart';
import 'package:ecotoken/widgets/customButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecoverPasswordView extends StatelessWidget {
  final controller = Get.put(RecoverPasswordViewController());

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
            CustomButton(onPressed: controller.recoverPassword, child: Text('Recuperar')),
          ],
        ),
      ),
    );
  }
}
