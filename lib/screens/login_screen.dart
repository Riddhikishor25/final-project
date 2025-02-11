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
  bool _obscurePassword = true; // 🔒 Password visibility state
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    emailController.text = "";
    passwordController.text = "";
  }

  Future<void> _loginWithApiService() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    if (isLoading) return; // Prevent multiple login attempts
    setState(() => isLoading = true);

    try {
      final result = await apiService.login(email, password);

      if (result == null) {
        _showErrorDialog("Unexpected error: No response from server.");
        return;
      }

      if (result.containsKey("message") &&
          result["message"] == "Login successful") {
        String token = result['token'];
        String username = result['user']; // ✅ Get username from backend

        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'username', value: username);

        if (!mounted) return;

        await _showSuccessDialog("Welcome back, $username!");

        // ✅ Navigate to HomeScreen **after** showing success dialog
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(username: username), // ✅ Pass username
            ),
          );
        }
      } else {
        _showErrorDialog(result["error"] ?? "Login failed. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Failed to login. Please check your network.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;
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

                // 🔹 Email Field
                _buildTextField(emailController, "Enter Email",
                    autofocus: true),
                const SizedBox(height: 15),

                // 🔹 Password Field with Toggle Icon
                _buildTextField(
                  passwordController,
                  "Password",
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Toggle state
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // 🔹 Forgot Password Link
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

                // 🔹 Continue Button
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

                // 🔹 Google Sign-In Button
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

                // 🔹 Continue as Guest
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(username: "Guest"),
                    ),
                  ),
                  child: const Text("Continue as a guest",
                      style: TextStyle(
                          fontSize: 16, decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 15),

                // 🔹 Sign Up Option
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
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

  // ✅ Re-added _buildTextField method
  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false, Widget? suffixIcon, bool autofocus = false}) {
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
        suffixIcon: suffixIcon,
      ),
    );
  }
}
