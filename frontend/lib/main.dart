import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/obsidian_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PharmaQApp(),
    ),
  );
}

class PharmaQApp extends ConsumerWidget {
  const PharmaQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PharmaQ',
      debugShowCheckedModeBanner: false,
      theme: ObsidianTheme.lightTheme,
      darkTheme: ObsidianTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
