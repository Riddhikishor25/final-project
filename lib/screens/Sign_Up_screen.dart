import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'authentication_database.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool isLoading = false;

  final ApiService apiService = ApiService(); // Instance of ApiService

  Future<void> _signUpWithEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Input validation
      if (_usernameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        _showErrorDialog("All fields are required.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        _showErrorDialog("Passwords do not match!");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final result = await apiService.signup(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      print("Signup API Response: $result"); // Debugging line

      if (result.containsKey("success") && result["success"] == true) {
        _showSuccessDialog("Sign-up successful! Please log in.");
      } else {
        _showErrorDialog(
            "Sign-up failed: ${result['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to sign up. Please try again.');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sign-Up Error"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context); // Redirect to login page
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                Image.asset(
                  'assets/illustrations/signup_logo.gif',
                  height: 210,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 25, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _buildTextField(_usernameController, "Enter Username"),
                const SizedBox(height: 15),
                _buildTextField(_emailController, "Enter Email"),
                const SizedBox(height: 15),
                _buildPasswordField(_passwordController, "Password", true),
                const SizedBox(height: 15),
                _buildPasswordField(
                    _confirmPasswordController, "Confirm Password", false),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 120,
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                const Text("or",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
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

  Widget _buildPasswordField(
      TextEditingController controller, String hintText, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_passwordVisible : !_confirmPasswordVisible,
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
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_passwordVisible ? Icons.visibility : Icons.visibility_off)
                : (_confirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _passwordVisible = !_passwordVisible;
              } else {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }
}
