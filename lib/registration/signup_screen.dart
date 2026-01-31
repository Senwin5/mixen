import 'package:flutter/material.dart';
import 'package:mixen/pages/completeprofilepage.dart';
import 'package:mixen/pages/swipe_page.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool isDarkMode = false; // 🌙 dark mode toggle
  String message = "";

  static const forestGreen = Color(0xFF2F855A);

  void signup() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final result = await ApiService.signup(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result['success'] == true) {
        setState(() {
          message = "Signup successful ✅";
        });

        final profileComplete = result['data']['profile_complete'] ?? false;

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
          message = result['error'] ?? "Signup failed ❌";
        });
      }
    } catch (e) {
      setState(() {
        message = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background based on dark mode
    final Color bgColor = isDarkMode ? Colors.black : const Color(0xFFF3FDE3);

    return Theme(
      data: isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: forestGreen),
            )
          : ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: forestGreen),
            ),
      child: Scaffold(
        backgroundColor: bgColor, // Dynamic background
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
                            color: isDarkMode ? Colors.white : forestGreen,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : forestGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Sign up to get started",
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Signup Card
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
                                obscureText: false,
                              ),
                              const SizedBox(height: 16),
                              AppInputField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                obscureText: false,
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

                              // Signup Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : signup,
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
                                            "Sign Up",
                                            key: ValueKey("text"),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Already have account? Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an account? "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: forestGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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

// Reuse the same AppInputField widget
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
