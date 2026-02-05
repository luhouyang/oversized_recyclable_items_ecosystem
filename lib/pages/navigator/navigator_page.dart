import 'package:flutter/material.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/navigator/large_navigator_page.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/navigator/small_navigator_page.dart';
import 'package:oversized_recyclable_items_ecosystem/states/constants.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > Constants().largeScreenWidth ? LargeNavigatorPage() : SmallNavigatorPage();
  }
}
