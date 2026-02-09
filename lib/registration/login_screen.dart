import 'package:flutter/material.dart';
import 'package:mixen/pages/completeprofilepage.dart';
import '../services/api_service.dart';
import '../pages/swipe_page.dart';
import '../registration/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String message = "";
  bool isLoading = false;
  bool obscurePassword = true;
  bool isDarkMode = false; // 🌙 dark mode toggle

  static const forestGreen = Color(0xFF2F855A);

  // Light mode background color
  //final Color lightBackgroundColor = const Color.fromARGB(255, 243, 253, 227);

  void login() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final result = await ApiService.login(
        usernameController.text,
        passwordController.text,
      );

      if (result['success'] == true) {
        setState(() {
          message = "Login successful ✅";
        });

        final profileComplete =
            result['data']['profile_complete'] ?? false;

        if (!mounted) return;

        if (!profileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CompleteProfilePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SwipePage(),
            ),
          );
        }
      } else {
        setState(() {
          message = "Login failed ❌: ${result['error']}";
        });
      }
    } catch (e) {
      setState(() {
        message = "An error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: forestGreen),
            )
          : ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: forestGreen),
            ),
      child: Scaffold(
       // backgroundColor: isDarkMode ? Colors.black : lightBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Builder(
              builder: (context) {
                final width = MediaQuery.of(context).size.width;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width > 600 ? 420 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🌙 Dark mode toggle with spacing
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              isDarkMode = !isDarkMode;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Header
          
                        Column(
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              size: 72,
                              color: forestGreen, // ✅ Match button color
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: forestGreen, // ✅ Match button color
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Login to continue",
                            ),
                          ],
                        ),


                      const SizedBox(height: 32),

                      // Login Card
                      Card(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        elevation: isDarkMode ? 2 : 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              AppInputField(
                                controller: usernameController,
                                label: "Username",
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              AppInputField(
                                controller: passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: obscurePassword,
                                suffix: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Login Button with loader
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: forestGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: isLoading
                                        ? const SizedBox(
                                            key: ValueKey("loader"),
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            "Login",
                                            key: ValueKey("text"),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              if (message.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: message.contains("successful")
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign Up Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  const AppInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.grey.shade700,
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
