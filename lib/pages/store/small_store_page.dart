import 'package:flutter/material.dart';

class SmallStorePage extends StatefulWidget {
  const SmallStorePage({super.key});

  @override
  State<SmallStorePage> createState() => _SmallStorePageState();
}

class _SmallStorePageState extends State<SmallStorePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("STORE PAGE"),);
  }
}