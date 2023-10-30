import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/global_inventory_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/inventory_list_view.dart';

class InventorySearchDelegate extends SearchDelegate {
  final InventoryOwnerRelationship invOwnRel;
  final bool isPersonalInventory;

  InventorySearchDelegate({
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.keyboardType,
    super.textInputAction,
    required this.invOwnRel,
    required this.isPersonalInventory,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        iconSize: 30,
        onPressed: () => {query = ""},
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      iconSize: 30,
      onPressed: () => {close(context, "")},
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return InventoryListView(
      invOwnRel: invOwnRel,
      isPersonalInventory: isPersonalInventory,
      searchCriteria: "",
      tiledView: false,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return InventoryListView(
      invOwnRel: invOwnRel,
      isPersonalInventory: isPersonalInventory,
      searchCriteria: "",
      tiledView: false,
    );
  }
}

class GlobalInventorySearchDelegate extends SearchDelegate {
  final String uid;

  GlobalInventorySearchDelegate({
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.keyboardType,
    super.textInputAction,
    required this.uid,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        iconSize: 30,
        onPressed: () => {query = ""},
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      iconSize: 30,
      onPressed: () => {close(context, "")},
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return GlobalInventoryListView(
      uid: uid,
      searchCriteria: query,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return GlobalInventoryListView(
      uid: uid,
      searchCriteria: query,
    );
  }
}
