// ignore_for_file: use_build_context_synchronously
// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Login Page
import 'package:flutter/material.dart';
import 'main.dart';
import 'register.dart';
import 'database.dart';

class LoginTab extends StatelessWidget {
  final int? userId;
  final _formKey = GlobalKey<FormState>();

  LoginTab({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Regular expression for username: Allows letters, numbers, and underscores. Must start with a letter.
    RegExp usernameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

    // Regular expression for password: Must contain at least 8 characters including uppercase, lowercase, and numbers.
    RegExp passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');

    // Function to show error message in a dialog
    void showErrorMessage(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taste Fiesta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:60.0),
        child: SingleChildScrollView( 
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (!usernameRegExp.hasMatch(value)) {
                      return 'Please enter a valid username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!passwordRegExp.hasMatch(value)) {
                      return 'Password must contain at least 8 characters including uppercase, lowercase, and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    // Check if the form is valid
                    if (_formKey.currentState!.validate()) {
                      String userName = usernameController.text;
                      String password = passwordController.text;

                      // Verify login credentials
                      Map<String, dynamic> loginResult = await DatabaseService.instance.verifyLogin(userName, password);
                      bool isValid = loginResult['verified'];

                      if (isValid) {
                        int userId = loginResult['user_id'];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen(userId: userId)),
                        );
                      } else {
                        String errorMessage = loginResult['error'];
                        showErrorMessage(context, errorMessage);
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 5.0),
                GestureDetector(
                  onTap: () async {
                    usernameController.clear();
                    passwordController.clear();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterTab()), // link to register page
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
