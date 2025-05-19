import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_note_taking_app/screens/home_screen.dart';
import 'package:ai_note_taking_app/screens/login_screen.dart';
import 'package:ai_note_taking_app/providers/auth_provider.dart';
import 'package:ai_note_taking_app/providers/theme_provider.dart';
import 'package:ai_note_taking_app/providers/note_provider.dart';
import 'package:ai_note_taking_app/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'AI Note Taking App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return authProvider.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
} 