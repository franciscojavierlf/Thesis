import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/homeView.dart';
import 'package:ecotoken/views/hub/settingsView.dart';
import 'package:ecotoken/views/hub/socialView.dart';
import 'package:ecotoken/views/hub/trajectoriesView.dart';
import 'package:flutter/material.dart';

/// The view that contains all the main views.
class HubView extends StatefulWidget {
  final int? initialIndex;
  HubView(this.initialIndex);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<HubView> {
  late int selectedIndex;

  final List<Widget> _widgetOptions = [
    HomeView(),
    TrajectoriesView(),
    SocialView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nordic_walking),
            label: 'Trayectorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Opciones',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Palette.C,
        selectedItemColor: Colors.white,
        unselectedItemColor: Palette.D,
        currentIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
      ),
    );
  }
}
