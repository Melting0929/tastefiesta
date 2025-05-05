// ignore_for_file: use_build_context_synchronously
// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Profile Page
import 'package:flutter/material.dart';
import 'database.dart';
import 'login.dart';

class ProfileTab extends StatefulWidget {
  final int userId;

  const ProfileTab({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // ignore: non_constant_identifier_names
  String Username = '';
  

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetches user data from the database
  Future<void> _fetchUserData() async {
    Map<String, dynamic> userData = await DatabaseService.instance.getUserByID(widget.userId);
    setState(() {
      _usernameController.text = userData['username'];
      _emailController.text = userData['user_email'];
      _passwordController.text = userData['user_password'];
      Username = _usernameController.text;
    });
  }

  // Updates user data in the database
  Future<void> _updateUserData() async {
    String newUsername = _usernameController.text;
    String newEmail = _emailController.text;
    String newPassword = _passwordController.text;

    // Check if the new username is the same as the existing one
    if (newUsername != Username) {
      bool usernameExists = await DatabaseService.instance.checkUserExists(newUsername);

      if (usernameExists) {
        // Show error message if username already exists
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Username already exists, please choose another username.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Proceed with updating user data if form is valid and username doesn't exist
    if (_formKey.currentState!.validate()) {
      await DatabaseService.instance.updateUser(
        widget.userId,
        newUsername,
        newEmail,
        newPassword,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  // Logs out the user
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginTab()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ListView(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 1),
                    Text(
                      'UserID: ${widget.userId.toString()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        final RegExp usernameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$'); // username regrex
                        if (!usernameRegExp.hasMatch(value)) {
                          return 'Please enter a valid username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');// email regrex
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        final RegExp passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');// password regrex
                        if (!passwordRegExp.hasMatch(value)) {
                          return 'Password must contain at least 8 characters including uppercase, lowercase, and numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(height: 20), 
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}