import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/drawer/nav_drawer.dart';

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
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    bool isPortrait = deviceWidth <= FormFactor.portrait;
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
          backgroundColor: schoolFitnessBlue,
          foregroundColor: Colors.white,
          actions: actions),
      drawer: isPortrait ? NavDrawer(currentPageId: currentPageId) : null,
      body: isPortrait
          ? body
          : Row(
              children: [
                NavDrawer(currentPageId: currentPageId),
                Expanded(
                  child: body,
                ),
              ],
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}
