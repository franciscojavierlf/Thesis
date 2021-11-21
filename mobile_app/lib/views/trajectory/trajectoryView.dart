import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:flutter/material.dart';

class TrajectoryView extends StatelessWidget {
  final bool finished;

  TrajectoryView() : finished = false;
  TrajectoryView.finished() : finished = true;

  @override
  Widget build(BuildContext context) {
    return HubLayout(
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
