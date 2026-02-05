import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/admin/small_admin_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/home/small_home_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/profile/small_profile_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/store/small_store_page.dart';
import 'package:oversized_recyclable_items_ecosystem/states/app_state.dart';
import 'package:oversized_recyclable_items_ecosystem/states/user_state.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:provider/provider.dart';

class SmallNavigatorPage extends StatefulWidget {
  const SmallNavigatorPage({super.key});

  @override
  State<SmallNavigatorPage> createState() => _SmallNavigatorPageState();
}

class _SmallNavigatorPageState extends State<SmallNavigatorPage> {
  final iconListAuth = <IconData>[
    Icons.home_outlined,
    Icons.store_outlined,
    Icons.person_outline,
    Icons.map_outlined,
  ];

  final iconListNormal = <IconData>[
    Icons.home_outlined,
    Icons.store_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

        List<IconData> iconList = isLoggedIn ? iconListAuth : iconListNormal;

        Widget getPage(int index) {
          if (isLoggedIn) {
            if (index == 0) {
              return const SmallHomePage();
            } else if (index == 1) {
              return const SmallStorePage();
            } else if (index == 2) {
              return const SmallProfilePage();
            } else if (index == 3) {
              return const SmallAdminPage();
            }
          } else {
            if (index == 0) {
              return const SmallHomePage();
            } else if (index == 1) {
              return const SmallStorePage();
            } else if (index == 2) {
              return const SmallProfilePage();
            }
          }

          return const SmallHomePage();
        }

        return Scaffold(
          body: Column(
            children: [
              if (!kIsWeb) const SizedBox(height: 36),
              SizedBox(
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Image.asset('assets/profile_placeholder.jpg'),
                      const SizedBox(width: 12),
                      Text("Oversized Items", style: Theme.of(context).textTheme.displayMedium),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
              Expanded(child: getPage(appState.bottomNavIndex)),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive ? Theme.of(context).iconTheme.color : UIColor().gray;

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(iconList[index], size: 24, color: color)],
              );
            },
            backgroundColor: UIColor().mediumGray,
            activeIndex: appState.bottomNavIndex,
            splashColor: UIColor().celeste,
            gapLocation: GapLocation.none,
            onTap: (index) => appState.setBottomNavIndex(index),
          ),
        );
      },
    );
  }
}
