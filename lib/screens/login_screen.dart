import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import 'dashboard_shell_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showAdminForm = false;
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bool _isPasswordVisible = false;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Title with Pocket CTS
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'Pocket '),
                    TextSpan(
                      text: 'CTS',
                      style: TextStyle(color: primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Lottie Animation
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: Lottie.asset(
                    'assets/images/Animation.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          size: 120,
                          color: pocketBlue,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (!_showAdminForm) ...[
                // Welcome message
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Welcome to Headsup,\nwhere Your Workforce\nBecome ',
                      ),
                      TextSpan(
                        text: 'Empower',
                        style: TextStyle(color: primaryBlue),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Impactfull',
                        style: TextStyle(color: primaryBlue),
                      ),
                      TextSpan(text: ' Platform.'),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Google Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      handleGoogleLogin(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: buttonTextWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/google_logo.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'G',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    label: const Text('Sign In With Google'),
                  ),
                ),
                const SizedBox(height: 16),
                // Admin Login button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAdminForm = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryBlue, width: 2),
                      foregroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: primaryBlue,
                    ),
                    label: const Text('Admin Login'),
                  ),
                ),
              ] else ...[
                // Admin login form
                Text(
                  'Admin Access',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure administrative login',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 32),
                // Email field
                TextField(
                  controller: _adminEmailController,
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: _adminPasswordController,
                  obscureText:
                      !_isPasswordVisible, // This controls the visibility
                  decoration: InputDecoration(
                    labelText: 'Admin Password',
                    prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible =
                              !_isPasswordVisible; // Toggle visibility
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Admin login button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    // onPressed: () {
                    //   // Simple admin login logic
                    //   if (_adminEmailController.text == 'admin@headsup.com' &&
                    //       _adminPasswordController.text == 'admin123') {
                    //     Navigator.pushReplacement(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const DashboardShellScreen(isAdmin: true),
                    //       ),
                    //     );
                    //   } else {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Row(
                    //           children: const [
                    //             Icon(Icons.error, color: whiteColor),
                    //             SizedBox(width: 8),
                    //             Text('Invalid admin credentials'),
                    //           ],
                    //         ),
                    //         backgroundColor: primaryBlue,
                    //       ),
                    //     );
                    //   }
                    // },
                    // this will help to login admin using API
                    onPressed: () async {
                      final email = _adminEmailController.text.trim();
                      final password = _adminPasswordController.text.trim();

                      final authService = AuthService();
                      final data = await authService.login(email, password);

                      if (data != null) {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        await userProvider.setUser(
                          userId: data.id.toString(),
                          email: data.email,
                          name: data.name,
                          role: data.admin ? "admin" : "user",
                          accessToken: data.accessToken,
                          refreshToken: data.refreshToken,
                          tokenType: "Bearer",
                          admin: data.admin,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardShellScreen(isAdmin: true),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login successful")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.error, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Login failed: Invalid credentials'),
                              ],
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: whiteColor,
                    ),
                    label: const Text('Admin Login'),
                  ),
                ),
                const SizedBox(height: 16),
                // Cancel/back button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAdminForm = false;
                    });
                  },
                  child: Text('Back to User Login', style: TextStyle(color: primaryBlue)),
                ),
              ],
              const SizedBox(height: 16),
              // Powered by text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: 'Powered by '),
                    TextSpan(
                      text: 'Headsup HR',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleGoogleLogin(BuildContext context) async {
    final googleAuthService = GoogleAuthService();

    try {
      final googleUser = await googleAuthService.signInWithGoogle();
      if (googleUser == null) return; // User canceled

      final accessToken = await googleAuthService.getAccessToken(googleUser);
      if (accessToken == null) throw Exception('Google access token missing');

      final oauth2Response = await OAuth2Service.oauth2Login(
        provider: 'google',
        accessToken: accessToken,
        email: googleUser.email,
        name: googleUser.displayName ?? '',
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(
        userId: oauth2Response['userId'].toString(),
        email: oauth2Response['email'],
        name: oauth2Response['name'],
        role: (oauth2Response['admin'] ?? false) ? "admin" : "user",
        accessToken: oauth2Response['accessToken'],
        refreshToken: oauth2Response['refreshToken'],
        tokenType: oauth2Response['tokenType'] ?? "Bearer",
      );

      //       if (oauth2Response['admin'] == true) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      //   );
      // } else {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
      //   );
      // }

      // 🚀 Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DashboardShellScreen(), // You can use admin check here if needed
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
