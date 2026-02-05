import 'package:flutter/material.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/navigator/navigator_page.dart';
import 'package:oversized_recyclable_items_ecosystem/states/app_state.dart';
import 'package:oversized_recyclable_items_ecosystem/states/user_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: MaterialApp(
        title: 'Oversized Recyclable UTP',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
        home: const NavigatorPage(),
      ),
    );
  }
}
