import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NshutiTrackApp());
}

class NshutiTrackApp extends StatelessWidget {
  const NshutiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NshutiTrack',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AuthScreen(),
    );
  }
}
