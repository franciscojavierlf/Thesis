import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/blockchain/restConnection.dart';
import 'package:ecotoken/server/blockchain/walletsBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/utils/global.dart';
import 'package:ecotoken/views/trajectory/currentTrajectoryView.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:ecotoken/widgets/transportsTable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<HomeView> {
  final profile = Global.profile!;
  Wallet? wallet;
  var error = false;

  /// Gets the carbon impact of a transport from the authenticated profile.
  double carbonImpact(Transport transport) =>
      wallet?.carbonEmitted[transport] ?? 0;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  void loadWallet() async {
    try {
      WalletsBloc.getWallet(profile.wallet)
          .then((value) => setState(() => wallet = value));
    } catch (ex) {
      print(error);
      setState(() => error = true);
    }
  }

  final isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    loadWallet();

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
              onTap: () => goto(context, CurrentTrajectoryView(Transport.Metro),
                  replace: true),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Bus),
              backgroundColor: Palette.B,
              label: 'Autobús',
              onTap: () => goto(context, CurrentTrajectoryView(Transport.Bus),
                  replace: true),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Motorcycle),
              backgroundColor: Palette.B,
              label: 'Motocicleta',
              onTap: () => goto(
                  context, CurrentTrajectoryView(Transport.Motorcycle),
                  replace: true),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Bicycle),
              backgroundColor: Palette.B,
              label: 'Bicicleta',
              onTap: () => goto(
                  context, CurrentTrajectoryView(Transport.Bicycle),
                  replace: true),
            ),
            SpeedDialChild(
              child: TransportIcon(Transport.Walking),
              backgroundColor: Palette.B,
              label: 'Caminar',
              onTap: () => goto(
                  context, CurrentTrajectoryView(Transport.Walking),
                  replace: true),
            ),
          ],
        ),
        // Body
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: wallet == null
                  ? LoadingIndicator(
                      indicatorType: Indicator.ballGridPulse,
                      colors: [Palette.D],
                    ).centered.box(height: 50).paddingOnly(t: 100)
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
                          ElevatedButton(
                              onPressed: () =>
                                  print(RestConnection.get('/hello')),
                              child: Text('test')),
                          EcoText.h1('Hola, ${profile.name.first}'),
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
                                EcoText.h2(wallet!.tokens.toStringAsFixed(8)),
                              ],
                            ),
                          ).centered,
                          // End of tokens display
                          SizedBox(height: 20),
                          // Preferred transport
                          EcoText.h3('Transporte preferido').centered,
                          SizedBox(height: 10),
                          TransportIcon(
                            wallet!.preferredTransport,
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
                                  '${(wallet?.totalCarbonSaved ?? 0).toStringAsFixed(2)}kg',
                                  TransportIcon(Transport.Car))
                              .centered,
                          SizedBox(height: 30),
                          // Carbon impact
                          EcoText.h3('Tu impacto de carbono').centered,
                          SizedBox(height: 15),
                          TransportsTable(
                            motorcycle: carbonImpact(Transport.Motorcycle),
                            metro: carbonImpact(Transport.Metro),
                            bus: carbonImpact(Transport.Bus),
                            walking: carbonImpact(Transport.Walking),
                            bicycle: carbonImpact(Transport.Bicycle),
                          ).centered,
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
