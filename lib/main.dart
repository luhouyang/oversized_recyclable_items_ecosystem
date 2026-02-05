import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oversized_recyclable_items_ecosystem/firebase_options.dart';
import 'package:oversized_recyclable_items_ecosystem/pages/navigator/navigator_page.dart';
import 'package:oversized_recyclable_items_ecosystem/states/app_state.dart';
import 'package:oversized_recyclable_items_ecosystem/states/user_state.dart';
import 'package:oversized_recyclable_items_ecosystem/widgets/ui_color.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        debugShowCheckedModeBanner: false,
        title: 'Oversized Recyclable UTP',
        theme: lightTheme,
        home: const NavigatorPage(),
      ),
    );
  }
}
