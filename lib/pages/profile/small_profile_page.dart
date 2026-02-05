import 'package:flutter/material.dart';

class SmallProfilePage extends StatefulWidget {
  const SmallProfilePage({super.key});

  @override
  State<SmallProfilePage> createState() => _SmallProfilePageState();
}

class _SmallProfilePageState extends State<SmallProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("PROFILE PAGE"),);
  }
}