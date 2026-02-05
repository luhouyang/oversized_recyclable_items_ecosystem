import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/admin/large_admin_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/home/large_home_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/profile/large_profile_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/store/large_store_page.dart';
import 'package:oversized_recyclable_items_ecosystem/states/app_state.dart';
import 'package:oversized_recyclable_items_ecosystem/states/user_state.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:provider/provider.dart';

class NavItemModel {
  const NavItemModel({required this.idx, required this.name, required this.icon});

  final int idx;
  final String name;
  final IconData icon;
}

extension on Widget {
  Widget? showOrNull(bool isShow) => isShow ? this : null;
}

class LargeNavigatorPage extends StatefulWidget {
  const LargeNavigatorPage({super.key});

  @override
  State<LargeNavigatorPage> createState() => _LargeNavigatorPageState();
}

class _LargeNavigatorPageState extends State<LargeNavigatorPage> {
  final _sideMenuController = SideMenuController();

  final _navItems = const [
    NavItemModel(idx: 0, name: 'Home', icon: Icons.home_outlined),
    NavItemModel(idx: 1, name: 'Store', icon: Icons.store_outlined),
    NavItemModel(idx: 2, name: 'Profile', icon: Icons.person_outline),
  ];

  final _authItems = const [NavItemModel(idx: 3, name: 'Admin', icon: Icons.map_outlined)];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

        Widget getPage(int index) {
          if (isLoggedIn) {
            if (index == 0) {
              return const LargeHomePage();
            } else if (index == 1) {
              return const LargeStorePage();
            } else if (index == 2) {
              return const LargeProfilePage();
            } else if (index == 3) {
              return const LargeAdminPage();
            }
          } else {
            if (index == 0) {
              return const LargeHomePage();
            } else if (index == 1) {
              return const LargeStorePage();
            } else if (index == 2) {
              return const LargeProfilePage();
            }
          }

          return const LargeHomePage();
        }

        return Scaffold(
          body: Row(
            children: [
              SideMenu(
                backgroundColor: UIColor().mediumGray,
                hasResizerToggle: false,
                hasResizer: false,
                controller: _sideMenuController,
                mode: appState.isNavBarCollapsed ? SideMenuMode.compact : SideMenuMode.open,
                minWidth: 75,
                maxWidth: 270,
                builder: (data) {
                  return SideMenuData(
                    header: Column(
                      children: [
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onHover: (value) {},
                              onTap: () {
                                appState.setNavBarCollapsed(!appState.isNavBarCollapsed);
                              },
                              child:
                                  appState.isNavBarCollapsed
                                      ? Icon(
                                        Icons.menu_outlined,
                                        color: Theme.of(context).iconTheme.color,
                                      )
                                      : Icon(
                                        Icons.menu_open_outlined,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                            ),
                          ),
                          title: Text(
                            'Stuff App',
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: UIColor().white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).showOrNull(!appState.isNavBarCollapsed),
                        ),
                      ],
                    ),
                    items: [
                      ..._navItems.map(
                        (e) => SideMenuItemDataTile(
                          isSelected: e.idx == appState.bottomNavIndex,
                          onTap: () {
                            appState.setBottomNavIndex(e.idx);
                          },
                          title: e.name,
                          titleStyle: GoogleFonts.inter(
                            textStyle: TextStyle(color: UIColor().whiteSmoke, fontSize: 16),
                          ),
                          hoverColor:
                              e.idx == appState.bottomNavIndex
                                  ? UIColor().transparentCeleste
                                  : UIColor().transparentSpringGreen,
                          hasSelectedLine: false,
                          highlightSelectedColor: UIColor().transparentCeleste,
                          selectedTitleStyle: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          icon: Icon(
                            e.icon,
                            color:
                                e.idx == appState.bottomNavIndex
                                    ? Theme.of(context).iconTheme.color
                                    : UIColor().gray,
                          ),
                        ),
                      ),
                      if (!appState.isNavBarCollapsed && isLoggedIn)
                        SideMenuItemDataDivider(divider: Divider(color: UIColor().white)),
                      if (!appState.isNavBarCollapsed && isLoggedIn)
                        SideMenuItemDataTitle(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 8),
                          title: 'Tools',
                          titleStyle: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: UIColor().white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (isLoggedIn)
                        ..._authItems.map(
                          (e) => SideMenuItemDataTile(
                            isSelected: e.idx == appState.bottomNavIndex,
                            onTap: () {
                              appState.setBottomNavIndex(e.idx);
                            },
                            title: e.name,
                            titleStyle: GoogleFonts.inter(
                              textStyle: TextStyle(color: UIColor().white, fontSize: 16),
                            ),
                            hoverColor:
                                e.idx == appState.bottomNavIndex
                                    ? UIColor().transparentCeleste
                                    : UIColor().transparentSpringGreen,
                            hasSelectedLine: false,
                            highlightSelectedColor: UIColor().transparentCeleste,
                            selectedTitleStyle: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            icon: Icon(
                              e.icon,
                              color:
                                  e.idx == appState.bottomNavIndex
                                      ? Theme.of(context).iconTheme.color
                                      : UIColor().gray,
                            ),
                          ),
                        ),
                    ],
                    footer: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [],
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: getPage(appState.bottomNavIndex),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
