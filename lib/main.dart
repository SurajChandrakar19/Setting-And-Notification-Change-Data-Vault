import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_colors.dart';
import 'providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// replace with your home page
import '../screens/login_screen.dart';
import '../utils/token_storage.dart'; // Import your TokenStorage utility
import '../services/token_service.dart'; // Import your TokenService
import 'screens/dashboard_shell_screen.dart';

// Export for use in other files
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // restore user before runApp
  final userProvider = UserProvider();
  await userProvider.restoreUser();

  runApp(
    MultiProvider(
      // providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    print('Loaded dark mode preference: $isDarkMode');
    themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'HEADSUP HR SOLUTIONS',
          theme: ThemeData(
            primaryColor: primaryBlue,
            scaffoldBackgroundColor: backgroundWhite,
            cardColor: backgroundWhite,
            appBarTheme: const AppBarTheme(
              backgroundColor: backgroundWhite,
              elevation: 1,
              iconTheme: IconThemeData(color: textDark),
              titleTextStyle: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: buttonTextWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: primaryBlue,
              unselectedItemColor: textSecondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: backgroundWhite,
              elevation: 8.0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryBlue,
            scaffoldBackgroundColor: const Color(0xFF181A20),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF23262B),
              elevation: 1,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF4A90E2),
              unselectedItemColor: Colors.white70,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(0xFF23262B),
              elevation: 8.0,
            ),
            cardColor: const Color(0xFF23262B),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              titleLarge: TextStyle(color: Colors.white),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF23262B),
            ),
          ),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          // home: const OnboardingScreen(),
          home: const AppEntry(), // Start page logic moved to AppEntry
        );
      },
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  Future<Widget> _getStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingShown = prefs.getBool('isOnboardingShown') ?? false;

    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];

    if (!isOnboardingShown) {
      return const OnboardingScreen();
    } else if (accessToken != null && accessToken.isNotEmpty) {
      // ✅ Try refreshing access token before showing home
      final refreshed = await TokenService.refreshAccessToken();
      if (refreshed) {
        // return const HomeTabScreen();
        return const DashboardShellScreen();
      } else {
        return const LoginScreen();
      }
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return snapshot.data!;
        } else {
          // Fallback just in case null slips through
          return const LoginScreen();
        }
      },
    );
  }
}
