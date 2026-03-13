import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_theme.dart';

import 'features/scan/domain/entities/receipt_item.dart';
import 'features/scan/presentation/pages/camera_page.dart';
import 'features/review/presentation/pages/review_page.dart';

class ShellaPayApp extends StatelessWidget {
  ShellaPayApp({super.key});

  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) {
          final items = state.extra as List<ReceiptItem>? ?? [];
          return ReviewPage(extractedItems: items);
        },
      ),
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
