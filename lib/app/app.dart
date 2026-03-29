import 'package:flutter/material.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/constants/app_constants.dart';
import 'package:wirasasa/core/theme/app_theme.dart';

class WiraSasaApp extends StatelessWidget {
  const WiraSasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
