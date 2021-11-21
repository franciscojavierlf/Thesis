import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/hub/socialController.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SocialView extends StatelessWidget {
  final controller = Get.put(SocialController());

  @override
  Widget build(BuildContext context) {
    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EcoText.h2('Social'),
          SizedBox(height: 10),
          Obx(
            () => controller.wallets.value == null
                ? LoadingIndicator(
                    indicatorType: Indicator.ballRotate,
                    colors: [Palette.D],
                  ).box(height: 40)
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final wallet = controller.wallets.value![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        child: Column(
                          children: [
                            // First row
                            Row(
                              children: [
                                EcoText.pIcon(
                                  wallet.owner.name,
                                  TransportIcon(wallet.preferredTransport),
                                  bold: true,
                                ).expanded,
                                EcoText.p('#${index + 1}', bold: true),
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
                                    EcoText.h2(wallet.totalDistanceTravelled
                                        .toStringAsFixed(2)),
                                    EcoText.p('km'),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    EcoText.h2(
                                        wallet.totalTimeTravelled.niceString),
                                    EcoText.p('tiempo'),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    EcoText.h2(
                                        wallet.totalCarbonEmitted.toStringAsFixed(2)),
                                    EcoText.p(CO2),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).paddingAll(10),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemCount: controller.wallets.value!.length,
                  ),
          ),
        ],
      ),
    );
  }
}
