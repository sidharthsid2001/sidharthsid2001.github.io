import 'package:flutter/material.dart';
import 'package:money_manager/screens/home/screen_home.dart';

class MoneyManagerBottomNavigation extends StatelessWidget {
  const MoneyManagerBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ScreenHome.selectedIndexNotifier,
        builder: (BuildContext ctx, int updatedIndex, Widget? _) {
          return BottomNavigationBar(
              selectedItemColor: Colors.purple,
              unselectedItemColor: Colors.grey,
              currentIndex: updatedIndex,
              onTap: (newIndex) {
                ScreenHome.selectedIndexNotifier.value = newIndex;
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Transactions'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.category), label: 'Categories'),
              ]);
        });
  }
}
