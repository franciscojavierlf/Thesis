import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';

class TrajectoriesController extends GetxController {
  final mainController = Get.find<MainController>();

  final trajectories = Rxn<List<Trajectory>>();

  @override
  void onInit() {
    super.onInit();
    loadTrajectories();
  }

  void loadTrajectories() {
    TrajectoriesBloc.getTrajectories(owner: mainController.profile!)
        .then((value) => trajectories(value));
  }
}
