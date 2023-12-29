import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide GoogleAuthProvider;
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/models/initiliasation.dart';

import '../models/inventory_owner_relationship.dart';

class RegisterGate extends StatelessWidget {
  const RegisterGate({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = "";
    String displayName = "";
    if (FirebaseAuth.instance.currentUser != null) {
      uid = FirebaseAuth.instance.currentUser!.uid;
      displayName = FirebaseAuth.instance.currentUser!.displayName.toString();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AuthGate(),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: isUserInitialised(uid),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool? userExists = snapshot.data;
            if (userExists == true) {
              return FutureBuilder(
                  future: InventoryOwnerRelationship.get(uid),
                  builder: (context,
                      AsyncSnapshot<InventoryOwnerRelationship> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => InventoryScreen(
                              invOwnRel: snapshot.data!,
                            ),
                          ),
                        );
                      });
                      return const Text("Loading");
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return const Text("No data");
                    } else {
                      return const LoadingScreen();
                    }
                  });
            } else {
              initialiseUser(uid: uid, name: displayName);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const RegisterGate(),
                  ),
                );
              });
            }
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Text("No data");
          } else {
            return const LoadingScreen();
          }
          return const LoadingScreen();
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
