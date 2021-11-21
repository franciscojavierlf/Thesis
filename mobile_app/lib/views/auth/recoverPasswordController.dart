import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RecoverPasswordController extends GetxController {

  final formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
  }
  
  /// Validates the email.
  String? validateEmail(String value) {
    return GetUtils.isEmail(value) ? null : 'Introduce un correo válido.';
  }

  /// Recovers the password.
  void recoverPassword() {
    
  }
}