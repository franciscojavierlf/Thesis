import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/utils/gps.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:ecotoken/views/trajectory/trajectoryView.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:get/state_manager.dart';

class CurrentTrajectoryController extends GetxController {
  final mainController = Get.find<MainController>();

  final Transport transport;

  final stopwatch = StopWatchTimer();
  final paused = false.obs;
  int duration = 0;
  final List<GeoPoint> path = [];
  StreamSubscription<Position>? subscription;

  CurrentTrajectoryController(this.transport);

  @override
  void onInit() {
    super.onInit();
    GPS.getPositionStream().then((stream) {
      subscription = stream.listen((position) =>
          path.add(GeoPoint(position.latitude, position.longitude)));
      stopwatch.onExecute.add(StopWatchExecute.start);
    }).catchError((err) {
      Get.off(HubView());
    });
  }

  @override
  void onClose() {
    super.onClose();
    subscription?.cancel();
    stopwatch.dispose();
  }

  void pause() {
    stopwatch.onExecute.add(StopWatchExecute.stop);
    paused(true);
  }

  void play() {
    stopwatch.onExecute.add(StopWatchExecute.start);
    paused(false);
  }

  void stop(BuildContext context) {
    pause();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Text('¿Seguro que deseas terminar el trayecto?'),
        actions: [
          TextButton(
            child: Text('Terminar'),
            onPressed: finishTrajectory,
          ),
          TextButton(
            child: Text('Descartar'),
            onPressed: () => Get.off(HubView()),
          ),
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              play();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void finishTrajectory() async {
    // Saves trajectory
    try {
      await TrajectoriesBloc.addTrajectory(
        owner: mainController.profile!,
        duration: Duration(milliseconds: duration),
        path: path,
        transport: transport,
      );
      Get.off(TrajectoryView.finished());
    } catch (ex) {
      print(ex);
      Get.off(HubView());
    }
  }
}
