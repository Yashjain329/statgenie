import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main/main_navigation_screen.dart';
import 'screens/marketing/statgenie_home_screen.dart';
import 'screens/marketing/statgenie_upload_dashboard.dart';

class StatGenieApp extends StatefulWidget {
  const StatGenieApp({super.key});
  @override
  State<StatGenieApp> createState() => _StatGenieAppState();
}

class _StatGenieAppState extends State<StatGenieApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authed = context.read<AuthProvider>().isAuthenticated;
        final loc = state.matchedLocation; // current route path

        if (loc == '/splash') return null;
        if (!authed && !loc.startsWith('/auth')) return '/auth/login';
        if (authed && loc.startsWith('/auth')) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
        // Main 3-tab app
        GoRoute(path: '/home', builder: (_, __) => const MainNavigationScreen()),
        // Marketing landing + standalone upload dashboard
        GoRoute(path: '/landing', builder: (_, __) => StatGenieHomeScreen()),
        GoRoute(path: '/upload-dashboard', builder: (_, __) => const UploadDashboardScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StatGenie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}