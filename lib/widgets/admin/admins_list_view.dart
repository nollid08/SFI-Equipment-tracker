import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';

class AdminsListView extends StatefulWidget {
  final String searchCriteria;

  const AdminsListView({Key? key, required this.searchCriteria})
      : super(key: key);

  @override
  State<AdminsListView> createState() => _AdminsListViewState();
}

class _AdminsListViewState extends State<AdminsListView> {
  _AdminsListViewState();

  @override
  Widget build(BuildContext context) {
    //Using a stream builder to get the data from the Equipment Collection in the db, retrieve all equipment and return its name, total quantity and image in a ListView
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          //If there is an error, return a Text widget with the error
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          //If the connection is waiting, return a circular progress indicator
          return const Center(
            child: Center(
              child: SizedBox.square(
                dimension: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        void toggleAdmin(String uid, bool isAdmin) async {
          await Account.setAdminStatus(
            uid: uid,
            isAdmin: isAdmin,
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final String name = data['name'];
            final String uid = document.id;
            if (name.toLowerCase().contains(widget.searchCriteria)) {
              return Column(
                children: [
                  ListTile(
                    title: Text(name),
                    trailing: AdminSwitch(
                        data: data,
                        uid: uid,
                        toggleAdmin: (uid, isAdmin) =>
                            toggleAdmin(uid, isAdmin)),
                  ),
                  const Divider(),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        );
      },
    );
  }
}

class AdminSwitch extends StatefulWidget {
  const AdminSwitch({
    super.key,
    required this.data,
    required this.uid,
    required this.toggleAdmin,
  });

  final Map<String, dynamic> data;
  final String uid;
  final Function toggleAdmin;
  @override
  State<AdminSwitch> createState() => _AdminSwitchState();
}

class _AdminSwitchState extends State<AdminSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.data['isAdmin'],
      onChanged: (value) {
        setState(() {
          widget.toggleAdmin(widget.uid, value);
        });
      },
      activeTrackColor: Colors.lightGreenAccent,
      activeColor: Colors.green,
    );
  }
}
