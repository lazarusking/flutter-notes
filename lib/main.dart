import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/app_themes.dart';
import 'package:notes/homepage.dart';
import 'package:notes/providers/theme_provider.dart'; // Theme provider

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the theme mode from the Riverpod provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      home: const HomePage(),
      theme: AppThemes.lightTheme, // Define light theme in AppThemes
      darkTheme: AppThemes.darkTheme, // Define dark theme in AppThemes
      themeMode: themeMode, // Dynamically switch theme mode
    );
  }
}

  // runApp(ProviderScope(
  //     child: MaterialApp(
  //   home: const HomePage(),
  //   theme: ThemeData.dark().copyWith(
  //     scaffoldBackgroundColor: defaultColor,
  //     primaryColor: defaultColor,
  //   ),
  // )));

