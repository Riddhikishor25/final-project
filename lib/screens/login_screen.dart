import 'package:flutter/material.dart';
import 'authentication_database.dart'; // Import ApiService for authentication
import 'home_screen.dart'; // Navigate to HomeScreen after login
import 'recover_password_screen.dart'; // Navigate to RecoverPasswordScreen
import 'sign_up_screen.dart'; // Import SignUpScreen
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    emailController.text = ""; // Clear input fields on launch
    passwordController.text = "";
  }

  Future<void> _loginWithApiService() async {
    print("Login button clicked!");

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print("Error: Missing email or password.");
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    if (isLoading) return; // Prevent multiple login attempts
    setState(() => isLoading = true);

    try {
      print("Sending API request...");
      final result = await apiService.login(email, password);
      print("Full API Response: $result");

      if (result == null) {
        print("Error: API response is null.");
        _showErrorDialog("Unexpected error: No response from server.");
        return;
      }

      // ✅ FIXED: Check "message" instead of "success"
      if (result["message"] == "Login successful") {
        print("Login successful!");

        if (result.containsKey("token") && result.containsKey("user")) {
          String token = result['token'];
          String username =
              result['user']; // ✅ FIXED: "user" instead of "username"

          print("Received Token: $token");
          print("Received Username: $username");

          await _secureStorage.write(key: 'token', value: token);
          print("Token saved successfully!");

          if (!mounted) return;

          // Show success dialog before navigating
          await _showSuccessDialog("Welcome back, $username!");

          if (mounted) {
            print("Navigating to HomeScreen...");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          print("Error: Missing token or user in API response.");
          _showErrorDialog("Login response is missing required data.");
        }
      } else {
        print("Login failed: ${result["message"]}");
        _showErrorDialog(
            result["message"] ?? "Login failed. Please try again.");
      }
    } catch (e) {
      print("ERROR DURING LOGIN: $e");
      _showErrorDialog("Failed to login. Please check your network.");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Login Error"),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    });
  }

  // Show success dialog before navigating
  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/illustrations/login_logo.gif',
                    height: 210, fit: BoxFit.contain),
                const SizedBox(height: 5),
                const Text('Log in or Sign Up',
                    style: TextStyle(fontSize: 25, color: Colors.black54)),
                const SizedBox(height: 20),
                _buildTextField(emailController, "Enter Email",
                    autofocus: true),
                const SizedBox(height: 15),
                _buildTextField(passwordController, "Password",
                    obscureText: true),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecoverPasswordScreen()),
                    ),
                    child: const Text("Forgot Password?",
                        style: TextStyle(fontSize: 14, color: Colors.green)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _loginWithApiService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 120),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 10),
                const Text("or",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {}, // Add Google login function
                  icon: Image.asset('assets/icons/google_logo3.png',
                      height: 24, width: 24),
                  label: const Text("Continue with Google",
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.grey, width: 0.8)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen())),
                  child: const Text("Continue as a guest",
                      style: TextStyle(
                          fontSize: 16, decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen())),
                  child: const Text("Don't have an account? Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false, bool autofocus = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      autofocus: autofocus,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
