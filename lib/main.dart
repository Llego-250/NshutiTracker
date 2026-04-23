import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: bgDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: NshutiTrackApp()));
}

class NshutiTrackApp extends ConsumerWidget {
  const NshutiTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'NshutiTrack',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: auth.when(
        data: (user) => user != null ? const MainShell() : const AuthScreen(),
        loading: () => const _Splash(),
        error: (_, _) => const AuthScreen(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: bgDark,
        body: Center(
          child: CircularProgressIndicator(color: accentPurple),
        ),
      );
}
