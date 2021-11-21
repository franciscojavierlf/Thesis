import 'package:get/state_manager.dart';

class HubController extends GetxController {

  final selectedIndex = 0.obs;

  HubController(int? selectedIndex) {
    this.selectedIndex.value = selectedIndex ?? 0;
  }
}