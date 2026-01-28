import 'package:flutter/material.dart';
import '../services/api_service.dart'; // use your actual ApiService
import '../pages/swipe_page.dart'; // so we can go to next screen after login

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

      // ✅ LOGIN SUCCESS
      if (result['success'] == true) {
        setState(() {
          message = "Login successful ✅";
        });

        // Go to Swipe page after login
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SwipePage()),
        );
      } 
      // ❌ LOGIN FAILED
      else {
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
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
