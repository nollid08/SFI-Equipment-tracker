import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/screens/add_new_stock.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('My Inventory'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Business'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('School'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(
            height: 2,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Admin',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                    fontSize: 18),
              ),
            ),
          ),
          ListTile(
            title: const Text('Add New Stock'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNewStock()),
              );
            },
          ),
        ],
      ),
    );
  }
}
