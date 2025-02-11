import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool isLoading = false;

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  final String baseUrl = "http://192.168.59.92:5000"; // Flask server URL

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ **Check Username Availability**
  Future<void> _validateUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => usernameError = "Username is required.");
      return;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/check_username'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );
    final data = jsonDecode(response.body);
    setState(() {
      usernameError = data['exists'] ? "Username is already taken." : null;
    });
  }

  // ✅ **Validate Email**
  void _validateEmail() {
    final email = _emailController.text.trim();
    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email)) {
      setState(() => emailError = "Invalid email format.");
    } else {
      setState(() => emailError = null);
    }
  }

  // ✅ **Validate Password Strength**
  void _validatePassword() {
    final password = _passwordController.text.trim();
    if (!RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
        .hasMatch(password)) {
      setState(() => passwordError =
          "Password must be 8+ chars, include upper/lowercase, number, and symbol.");
    } else {
      setState(() => passwordError = null);
    }
  }

  // ✅ **Check Password Match**
  void _validateConfirmPassword() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => confirmPasswordError = "Passwords do not match.");
    } else {
      setState(() => confirmPasswordError = null);
    }
  }

  Future<void> _signUpWithEmail() async {
    if (usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _showSuccessDialog("Sign-up successful! Please log in.");
    } else {
      _showErrorDialog(data["error"] ?? "Sign-up failed.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sign-Up Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Navigate to Login Screen
            },
            child: Text("OK"),
          ),
        ],
      ),
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
              children: [
                Image.asset('assets/illustrations/signup_logo.gif',
                    height: 210),
                const SizedBox(height: 10),
                _buildTextField(_usernameController, "Enter Username",
                    _validateUsername, usernameError),
                const SizedBox(height: 15),
                _buildTextField(_emailController, "Enter Email", _validateEmail,
                    emailError),
                const SizedBox(height: 15),
                _buildPasswordField(_passwordController, "Password", true,
                    _validatePassword, passwordError),
                const SizedBox(height: 15),
                _buildPasswordField(
                    _confirmPasswordController,
                    "Confirm Password",
                    false,
                    _validateConfirmPassword,
                    confirmPasswordError),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 120),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("Already have an account? Log in",
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      VoidCallback onChanged, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: hintText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(errorText,
                style: TextStyle(color: Colors.red, fontSize: 14)),
          ),
      ],
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText,
      bool isPassword, VoidCallback onChanged, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText:
              isPassword ? !_passwordVisible : !_confirmPasswordVisible,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: hintText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            suffixIcon: IconButton(
              icon: Icon(isPassword
                  ? (_passwordVisible ? Icons.visibility : Icons.visibility_off)
                  : (_confirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off)),
              onPressed: () {
                setState(() {
                  if (isPassword)
                    _passwordVisible = !_passwordVisible;
                  else
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(errorText,
                style: TextStyle(color: Colors.red, fontSize: 14)),
          ),
      ],
    );
  }
}
