import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    GoogleProvider(clientId: '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'),
  ]);
  await FirebaseAppCheck.instance.activate(
    webProvider:
        ReCaptchaV3Provider('6LfaT0ApAAAAAOx0U6-yMw5nbYHb0lKzgg5IqXAb'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFI Inventory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: schoolFitnessBlue),
        primaryColor: schoolFitnessBlue,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
