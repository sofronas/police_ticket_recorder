import 'package:flutter/services.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class IntroApp extends StatelessWidget {
  const IntroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: FirstTimeScreen(),
    );
  }
}

// ignore: must_be_immutable
class FirstTimeScreen extends StatelessWidget {
  FirstTimeScreen({super.key});

  List<Introduction> list = [
    Introduction(
      title: 'Καλώς Ορίσατε',
      subTitle: 'Ας δούμε τι προσφέρει η εφαρμογή. ',
      imageUrl: 'assets/intro/intro.png',
    ),
    Introduction(
      title: 'Καταγραφή Παραβάσεων',
      subTitle: 'Η εφαρμογή αποτελεί ένα σύστημα αρχείου παραβάσεων.',
      imageUrl: 'assets/intro/policeticketman.png',
    ),
    Introduction(
      title: 'Ιστορικό Παραβάσεων',
      subTitle:
          'Εύκολη προβολή, επεξεργασία και αναζήτηση ιστορικού παραβάσεων ενός παραβάτη.',
      imageUrl: 'assets/intro/history.png',
    ),
    Introduction(
      title: 'Έτοιμοι!',
      subTitle: 'Είστε έτοιμοι για χρήση της εφαρμογής',
      imageUrl: 'assets/intro/ready.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      introductionList: list,
      skipTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      onTapSkipButton: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
    );
  }
}
