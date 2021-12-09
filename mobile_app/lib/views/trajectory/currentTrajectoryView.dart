import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/trajectory/currentTrajectoryController.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// A trajectory running.
class CurrentTrajectoryView extends StatelessWidget {
  final controller = Get.put(CurrentTrajectoryController());

  CurrentTrajectoryView(Transport transport) {
    controller.start(transport);
  }

  static const borderColor = Color(0xff797659);

  /// Special text for this screen.
  Text _specialText(
    String text, {
    double? size,
    bool bold = false,
  }) =>
      Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      );

  /// Special button for this screen.
  ElevatedButton _specialButton({
    required Color color,
    required void Function() onPressed,
    required Widget child,
  }) =>
      ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(90),
            ),
          ),
          padding: MaterialStateProperty.all(EdgeInsets.all(20)),
          backgroundColor: MaterialStateProperty.all(color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Palette.A,
      body: SafeArea(
        child: Column(
          children: [
            // Time
            Container(
              height: screen.height * 0.2,
              width: screen.width,
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 5)),
              ),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: -15,
                children: [
                  StreamBuilder<int>(
                      stream: controller.stopwatch.rawTime,
                      initialData: 0,
                      builder: (context, snapshot) {
                        controller.duration = snapshot.data ?? 0;
                        bool hours = false;
                        if (controller.duration / 6000000 > 1) hours = true;
                        final displayTime = StopWatchTimer.getDisplayTime(
                          controller.duration,
                          milliSecond: false,
                          hours: hours,
                        );
                        return _specialText(displayTime,
                            size: 46.px, bold: true);
                      }),
                  _specialText('Tiempo', size: 18.px),
                ],
              ).centered,
            ),
            // Distance
            Container(
              height: screen.height * 0.3,
              width: screen.width,
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 5)),
              ),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: -25,
                children: [
                  Obx(() => _specialText(
                      controller.distance.value.toStringAsFixed(2),
                      size: 80.px,
                      bold: true)),
                  _specialText('Kilómetros', size: 20.px),
                ],
              ).centered,
            ),
            // Transport and emitted CO2
            Row(
              children: [
                Container(
                  height: screen.height * 0.25,
                  width: screen.width * 0.5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 5),
                      right: BorderSide(color: borderColor, width: 5),
                    ),
                  ),
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: -10,
                    children: [
                      TransportIcon(controller.transport!,
                          color: Colors.white, size: 75),
                      _specialText('Transporte', size: 18.px),
                    ],
                  ).centered,
                ),
                Container(
                  height: screen.height * 0.25,
                  width: screen.width * 0.5,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: borderColor, width: 5)),
                  ),
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: -15,
                    children: [
                      _specialText('0.1', size: 46.px, bold: true),
                      _specialText('$CO2 (kg)', size: 18.px),
                    ],
                  ).centered,
                ),
              ],
            ),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => controller.paused.value
                      ?
                      // Play button
                      _specialButton(
                          color: Color(0xffEEE062).withOpacity(0.6),
                          onPressed: controller.play,
                          child: Icon(Icons.play_arrow,
                              size: screen.height * 0.075),
                        )
                      :
                      // Pause button
                      _specialButton(
                          color: Color(0xffA19C72).withOpacity(0.6),
                          onPressed: controller.pause,
                          child: Icon(Icons.pause, size: screen.height * 0.075),
                        ),
                ),
                // Stop button
                _specialButton(
                  color: Palette.E,
                  onPressed: () => controller.stop(context),
                  child: Icon(Icons.stop, size: screen.height * 0.075),
                ),
              ],
            ).expanded,
          ],
        ),
      ),
    );
  }
}
