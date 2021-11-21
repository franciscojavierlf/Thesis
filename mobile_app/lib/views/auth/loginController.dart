import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  late final GlobalKey<FormState> formKey;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final message = ''.obs;
  final loading = false.obs;
  final success = false.obs;

  @override
  onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
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

  void tryLogin() async {
    if (formKey.currentState!.validate()) {
      try {
        loading(true);
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        message.value = '¡Inicio de sesión logrado!';
        loading(false);
        success(true);
      } catch (err) {
        print(err);
        loading(false);
        message('El correo o contraseña son inválidos.');
      }
    }
  }
}
