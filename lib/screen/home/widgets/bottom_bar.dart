import 'package:flutter/material.dart';
import 'package:flutter_app_test1/helpers/app_setting.dart';
import 'package:get/get.dart';

class BottomBar extends StatelessWidget {
  BottomBar({super.key});
  AppSettingController controller = Get.put(AppSettingController());

  static const _radiusBorderMenu = 16.0;
  final int indexMain = 1;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_radiusBorderMenu),
        topRight: Radius.circular(_radiusBorderMenu),
      ),
      child: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: List.generate(
            controller.menuBarItems.length,
            (index) => BottomNavigationBarItem(
              label: controller.menuBarItems[index].label,
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: controller.menuBarItems[index].icon,
              ),
            ),
          ),

          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,

          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.setSelectedIndex(index);
          },
        ),
      ),
    );
  }
}
