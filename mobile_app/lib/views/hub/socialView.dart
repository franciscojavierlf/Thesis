import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/blockchain/walletsBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SocialView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SocialView> {
  List<Wallet>? wallets;

  @override
  void initState() {
    super.initState();
    WalletsBloc.getWallets().then((value) => setState(() => wallets = value));
  }

  @override
  Widget build(BuildContext context) {
    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EcoText.h2('Social'),
          SizedBox(height: 10),
          wallets == null
              ? LoadingIndicator(
                  indicatorType: Indicator.ballRotate,
                  colors: [Palette.D],
                ).box(height: 40)
              : ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final wallet = wallets![index];
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
                                  EcoText.h2(wallet.totalCarbonEmitted
                                      .toStringAsFixed(2)),
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
                  itemCount: wallets!.length,
                ),
        ],
      ),
    );
  }
}
