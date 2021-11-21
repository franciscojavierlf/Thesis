import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/hub/trajectoriesController.dart';
import 'package:ecotoken/views/trajectory/trajectoryView.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

class TrajectoriesView extends StatelessWidget {
  final controller = Get.put(TrajectoriesController());

  @override
  Widget build(BuildContext context) {
    controller.loadTrajectories();

    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EcoText.h2('Tus trajectorias'),
          SizedBox(height: 10),
          Obx(
            () => controller.trajectories.value == null
                ? LoadingIndicator(
                    indicatorType: Indicator.ballRotate,
                    colors: [Palette.D],
                  ).box(height: 40)
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final trajectory = controller.trajectories.value![index];
                      return GestureDetector(
                        onTap: () => Get.to(TrajectoryView(trajectory)),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Wrap(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      EcoText.h2(trajectory.distance
                                          .toStringAsFixed(2)),
                                      EcoText.p('km'),
                                    ],
                                  ),
                                  Wrap(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      EcoText.h2(
                                          trajectory.duration.niceString),
                                      EcoText.p('tiempo'),
                                    ],
                                  ),
                                  Wrap(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
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
                    itemCount: controller.trajectories.value!.length,
                  ),
          ),
        ],
      ),
    );
  }
}
