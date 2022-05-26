import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/utils/global.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/trajectory/trajectoryView.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class TrajectoriesView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TrajectoriesView> {
  List<Trajectory>? trajectories;
  final profile = Global.profile!;

  @override
  void initState() {
    super.initState();
    loadTrajectories();
  }

  void loadTrajectories() {
    TrajectoriesBloc.getTrajectories(profile)
        .then((value) => setState(() => trajectories = value));
  }

  @override
  Widget build(BuildContext context) {
    loadTrajectories();

    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EcoText.h2('Tus trajectorias'),
          SizedBox(height: 10),
          trajectories == null
              ? LoadingIndicator(
                  indicatorType: Indicator.ballRotate,
                  colors: [Palette.D],
                ).box(height: 40)
              : ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final trajectory = trajectories![index];
                    return GestureDetector(
                      onTap: () => goto(context, TrajectoryView(trajectory)),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        child: Column(
                          children: [
                            // First row
                            Row(
                              children: [
                                EcoText.pIcon(
                                  trajectory.finish.niceString,
                                  TransportIcon(trajectory.transport),
                                  bold: true,
                                ).expanded,
                                EcoText.pIcon(
                                  trajectory.tokens.toStringAsFixed(2),
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 20,
                                  ),
                                  bold: true,
                                ),
                              ],
                            ),
                            // Second row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    EcoText.h2(
                                        trajectory.distance.toStringAsFixed(2)),
                                    EcoText.p('km'),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    EcoText.h2(trajectory.duration.niceString),
                                    EcoText.p('tiempo'),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    EcoText.h2(trajectory.carbonEmitted
                                        .toStringAsFixed(2)),
                                    EcoText.p(CO2),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).paddingAll(10),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: trajectories!.length,
                ),
        ],
      ),
    );
  }
}
