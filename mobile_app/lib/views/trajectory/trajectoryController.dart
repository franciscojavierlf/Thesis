import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:ecotoken/views/hub/trajectoriesView.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class TrajectoryController extends GetxController {
  final Trajectory trajectory;

  TrajectoryController(this.trajectory);

  final loading = false.obs;

  void uploadTrajectory() async {
    loading(true);
    try {
      await TrajectoriesBloc.addTrajectory(trajectory);
      loading(false);
    } catch (ex) {
      print('Error adding trajectory');
      loading(false);
    }
    Get.offAll(HubView(1));
  }
}
