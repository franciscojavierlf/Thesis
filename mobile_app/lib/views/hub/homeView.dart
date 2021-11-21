import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/views/trajectory/currentTrajectoryView.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/homeController.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:ecotoken/widgets/splashScreen.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:get/state_manager.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomeView extends StatelessWidget {
  final mainController = Get.find<MainController>();
  final controller = Get.put(HomeController());

  final isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final leftColumnPadding = 20.0;
    final rightColumnPadding = 30.0;

    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else
          return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xfff4eeaf),
        // FAB
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.play_pause,
          openCloseDial: isDialOpen,
          backgroundColor: Palette.A,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 10,
          spaceBetweenChildren: 10,
          closeManually: false,
          children: [
            SpeedDialChild(
              child: TransportIcon(Transport.Metro),
              backgroundColor: Palette.B,
              label: 'Metro',
              onTap: () => Get.off(CurrentTrajectoryView(Transport.Metro)),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Bus),
              backgroundColor: Palette.B,
              label: 'Autobús',
              onTap: () => Get.off(CurrentTrajectoryView(Transport.Bus)),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Motorcycle),
              backgroundColor: Palette.B,
              label: 'Motocicleta',
              onTap: () => Get.off(CurrentTrajectoryView(Transport.Motorcycle)),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Bicycle),
              backgroundColor: Palette.B,
              label: 'Bicicleta',
              onTap: () => Get.off(CurrentTrajectoryView(Transport.Bicycle)),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Walking),
              backgroundColor: Palette.B,
              label: 'Caminar',
              onTap: () => Get.off(CurrentTrajectoryView(Transport.Walking)),
            ),
          ],
        ),
        // Body
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Obx(
                () => controller.wallet.value == null
                    ? LoadingIndicator(
                        indicatorType: Indicator.ballGridPulse,
                        colors: [Palette.D],
                      ).centered.box(height: 50).paddingOnly(top: 100)
                    : Container(
                        padding: EdgeInsets.all(25),
                        height: constraints.maxHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xfff4eeaf),
                              Color(0xfff2f0db),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EcoText.h1(
                                'Hola, ${mainController.profile?.name.first}'),
                            SizedBox(height: 25),
                            // Tokens display
                            Container(
                              height: 65,
                              width: screen.width * 0.75,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Image.asset('assets/images/logo.png',
                                      height: 45),
                                  SizedBox(width: 25),
                                  EcoText.h2(controller.wallet.value!.tokens
                                      .toStringAsFixed(8)),
                                ],
                              ),
                            ).centered,
                            // End of tokens display
                            SizedBox(height: 20),
                            // Preferred transport
                            EcoText.h3('Transporte preferido').centered,
                            SizedBox(height: 10),
                            TransportIcon(
                              controller.wallet.value!.preferredTransport,
                              size: 40,
                              padding: EdgeInsets.all(15),
                              backgroundColor: Palette.C,
                            ).centered,
                            // Saved CO2
                            SizedBox(height: 15),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                EcoText.h3('Has ahorrado'),
                                Tooltip(
                                  message:
                                      'Cantidad de $CO2 ahorrada si se hubiera usado un coche.',
                                  triggerMode: TooltipTriggerMode.tap,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screen.width * 0.15),
                                  child: EcoText.h4(' (?)'),
                                ),
                              ],
                            ).centered,
                            SizedBox(height: 10),
                            EcoText.pIcon(
                                    '${(controller.wallet.value?.totalCarbonSaved ?? 0).toStringAsFixed(2)}kg',
                                    TransportIcon(Transport.Car))
                                .centered,
                            SizedBox(height: 30),
                            // Carbon impact
                            EcoText.h3('Tu impacto de carbono').centered,
                            SizedBox(height: 15),
                            Table(
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: EcoText.pIcon(
                                                'Motocicleta',
                                                TransportIcon(
                                                    Transport.Motorcycle,
                                                    size: 16),
                                                end: true)
                                            .align(Alignment.centerRight)
                                            .paddingOnly(
                                                right: leftColumnPadding)),
                                    TableCell(
                                        child: EcoText.p(
                                                '${controller.carbonImpact(Transport.Motorcycle).toStringAsFixed(2)}kg')
                                            .paddingOnly(
                                                left: rightColumnPadding)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: EcoText.pIcon(
                                                'Metro',
                                                TransportIcon(Transport.Metro,
                                                    size: 16),
                                                end: true)
                                            .align(Alignment.centerRight)
                                            .paddingOnly(
                                                right: leftColumnPadding)),
                                    TableCell(
                                        child: EcoText.p(
                                                '${controller.carbonImpact(Transport.Metro).toStringAsFixed(2)}kg')
                                            .paddingOnly(
                                                left: rightColumnPadding)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: EcoText.pIcon(
                                                'Autobús',
                                                TransportIcon(Transport.Bus,
                                                    size: 16),
                                                end: true)
                                            .align(Alignment.centerRight)
                                            .paddingOnly(
                                                right: leftColumnPadding)),
                                    TableCell(
                                        child: EcoText.p(
                                                '${controller.carbonImpact(Transport.Bus).toStringAsFixed(2)}kg')
                                            .paddingOnly(
                                                left: rightColumnPadding)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: EcoText.pIcon(
                                                'Caminata',
                                                TransportIcon(Transport.Walking,
                                                    size: 16),
                                                end: true)
                                            .align(Alignment.centerRight)
                                            .paddingOnly(
                                                right: leftColumnPadding)),
                                    TableCell(
                                        child: EcoText.p(
                                                '${controller.carbonImpact(Transport.Walking).toStringAsFixed(2)}kg')
                                            .paddingOnly(
                                                left: rightColumnPadding)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                        child: EcoText.pIcon(
                                                'Bicicleta',
                                                TransportIcon(Transport.Bicycle,
                                                    size: 16),
                                                end: true)
                                            .align(Alignment.centerRight)
                                            .paddingOnly(
                                                right: leftColumnPadding)),
                                    TableCell(
                                        child: EcoText.p(
                                                '${controller.carbonImpact(Transport.Bicycle).toStringAsFixed(2)}kg')
                                            .paddingOnly(
                                                left: rightColumnPadding)),
                                  ],
                                ),
                              ],
                            ).centered,
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
