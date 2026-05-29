import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/router.dart';
import '../app/theme/day_theme.dart';
import '../widgets/session_resume_listener.dart';

class FlowClockApp extends ConsumerWidget {
  const FlowClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = DayTheme.forDate(DateTime.now());
    return SessionResumeListener(
      child: MaterialApp.router(
        title: 'Flow Clock',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        locale: const Locale('zh', 'CN'),
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: theme.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: theme.primary,
            surface: theme.background,
          ),
          fontFamily: 'sans-serif',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
