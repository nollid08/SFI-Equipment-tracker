import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';

class AdaptedScaffold extends StatelessWidget {
  const AdaptedScaffold({
    super.key,
    required this.title,
    required this.currentPageId,
    required this.body,
    this.floatingActionButton,
    this.actions = const [],
    this.bottom,
  });
  final List<Widget> actions;
  final String title;
  final String currentPageId;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          bottom: bottom,
          centerTitle: true,
          backgroundColor: SchoolFitnessBlue,
          foregroundColor: Colors.white,
          actions: actions),
      drawer: NavDrawer(currentPageId: currentPageId),
      body: body,
    );
  }
}
