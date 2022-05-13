import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/homeView.dart';
import 'package:ecotoken/views/hub/hubController.dart';
import 'package:ecotoken/views/hub/settingsView.dart';
import 'package:ecotoken/views/hub/socialView.dart';
import 'package:ecotoken/views/hub/trajectoriesView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The view that contains all the main views.
class HubView extends StatefulWidget {
  HubView(int? selectedIndex) {
    Get.put(HubController(selectedIndex));
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static final List<Widget> _widgetOptions = [
    HomeView(),
    TrajectoriesView(),
    SocialView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: _widgetOptions.elementAt(controller.selectedIndex.value),
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
            currentIndex: controller.selectedIndex.value,
            onTap: (value) => controller.selectedIndex(value),
          ),
        ));
  }
}
