import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final message = ''.obs;

  @override
  onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
  }

  /// Validates the email.
  String? validateEmail(String value) {
    return GetUtils.isEmail(value) ? null : 'Introduce un correo válido.';
  }

  void tryLogin() {
    if (formKey.currentState!.validate()) {
      
    }
  }
}