import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';

class ShellaPayApp extends StatelessWidget {
  ShellaPayApp({super.key});

  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('ShellaPay Scaffold - Replace with Splash/Login')),
        ),
      ),
      // Features routes will be added here
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShellaPay',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
