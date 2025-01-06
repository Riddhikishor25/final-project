import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecoverPasswordScreen extends StatefulWidget {
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _selectedMethod = 'email'; // Default method is email

  // Method to send OTP
  void _sendOTP() async {
    final input = _selectedMethod == 'email'
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    if (input.isEmpty) {
      _showMessage("Please enter your $_selectedMethod.");
      return;
    }

    final url = 'http://192.168.1.7:3000/send-otp';
    final body = {
      if (_selectedMethod == 'phone') 'phoneNumber': input,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        _showMessage("OTP has been sent to your $_selectedMethod.",
            isError: false);
      } else {
        _showMessage(responseJson['message'] ?? "Failed to send OTP.");
      }
    } catch (e) {
      _showMessage("Error: Unable to send OTP. Please try again.");
    }
  }

  // Method to verify OTP
  void _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showMessage("Please enter the OTP sent to your $_selectedMethod.");
      return;
    }

    final input = _selectedMethod == 'email'
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    final url = 'http://192.168.1.7:3000/verify-otp';
    final body = {
      'otp': otp,
      if (_selectedMethod == 'phone') 'phoneNumber': input,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        _showMessage("OTP verified successfully.", isError: false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
        );
      } else {
        _showMessage(
            responseJson['message'] ?? "Invalid OTP or verification failed.");
      }
    } catch (e) {
      _showMessage("Error: Unable to verify OTP. Please try again.");
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/illustrations/login_logo.gif',
                  height: 210,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Recover Password',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter your recovery information, and we’ll send you an OTP to reset your password.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'email',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                          _phoneController.clear();
                        });
                      },
                    ),
                    const Text('Email'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'phone',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                          _emailController.clear();
                        });
                      },
                    ),
                    const Text('Phone'),
                  ],
                ),
                const SizedBox(height: 20),
                _selectedMethod == 'email'
                    ? TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration("Enter your email"),
                      )
                    : TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            _buildInputDecoration("Enter your phone number"),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendOTP,
                  child: const Text("Send OTP"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration("Enter OTP"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOTP,
                  child: const Text("Verify OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _resetPassword() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match.");
      return;
    }

    // Send password to backend
    final url = 'http://192.168.1.7:3000/reset-password';

    http
        .post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'password': password}),
    )
        .then((response) {
      if (response.statusCode == 200) {
        _showMessage("Password reset successfully.", isError: false);
        Navigator.pop(context);
      } else {
        _showMessage("Failed to reset password.");
      }
    }).catchError((_) {
      _showMessage("Error resetting password.");
    });
  }

  void _showMessage(String message, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _buildInputDecoration("Enter new password"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _buildInputDecoration("Confirm new password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
    );
  }
}
