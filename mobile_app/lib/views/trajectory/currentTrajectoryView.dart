import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/utils/global.dart';
import 'package:ecotoken/utils/gps.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:ecotoken/views/trajectory/trajectoryView.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// A trajectory running.
class CurrentTrajectoryView extends StatefulWidget {
  final Transport transport;

  CurrentTrajectoryView(this.transport);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CurrentTrajectoryView> {
  final profile = Global.profile!;
  final borderColor = Color(0xff797659);


  var stopwatch = StopWatchTimer();
  var paused = false;
  var distance = 0.0;
  int duration = 0; // Updated in the view
  bool first = false;
  final List<GeoPoint> path = [];
  StreamSubscription<Position>? subscription;

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    stopwatch.dispose();
  }

  @override
  void initState() {
    super.initState();
    stopwatch = StopWatchTimer();
    path.clear();
    GPS.getPositionStream().then((stream) {
      subscription = stream.listen((position) {
        final point = GeoPoint(position.latitude, position.longitude);
        if (!first)
          first = true;
        else
          setState(() => distance += path.last.distance(point));
        path.add(point);
      });
      stopwatch.onExecute.add(StopWatchExecute.start);
    }).catchError((err) {
      goto(context, HubView(0), replace: true);
    });
    first = false;
  }

  void pause() {
    stopwatch.onExecute.add(StopWatchExecute.stop);
    setState(() => paused = true);
  }

  void play() {
    stopwatch.onExecute.add(StopWatchExecute.start);
    setState(() => paused = false);
  }

  void stop() {
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
            onPressed: () => goto(context, HubView(0), replace: true),
          ),
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              play();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void finishTrajectory() async {
    // Saves trajectory
    try {
      final trajectory = Trajectory.before(
        finish: DateTime.now(),
        owner: profile,
        duration: Duration(milliseconds: duration),
        path: path,
        transport: widget.transport,
      );
      goto(context, TrajectoryView.finished(trajectory));
    } catch (ex) {
      print(ex);
      goto(context, HubView(0), replace: true);
    }
  }

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
                      stream: stopwatch.rawTime,
                      initialData: 0,
                      builder: (context, snapshot) {
                        duration = snapshot.data ?? 0;
                        bool hours = false;
                        if (duration / 6000000 > 1) hours = true;
                        final displayTime = StopWatchTimer.getDisplayTime(
                          duration,
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
                  _specialText(
                      distance.toStringAsFixed(2),
                      size: 80.px,
                      bold: true),
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
                      TransportIcon(widget.transport,
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
                paused
                      ?
                      // Play button
                      _specialButton(
                          color: Color(0xffEEE062).withOpacity(0.6),
                          onPressed: play,
                          child: Icon(Icons.play_arrow,
                              size: screen.height * 0.075),
                        )
                      :
                      // Pause button
                      _specialButton(
                          color: Color(0xffA19C72).withOpacity(0.6),
                          onPressed: pause,
                          child: Icon(Icons.pause, size: screen.height * 0.075),
                        ),
                
                // Stop button
                _specialButton(
                  color: Palette.E,
                  onPressed: stop,
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
