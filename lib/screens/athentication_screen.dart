import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widget/img_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // New username controller
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>(); // Form key to manage the form state
  bool _isLogin = false; // Added isLogin logic

  Future<void> _submitForm() async {
    final isValid =
    _formKey.currentState!.validate(); // Trigger form validation
    if (!isValid) return;

    if (isValid ?? false) {
      if (_isLogin) {
        final userCrenditals = await _firebase.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        //LOG USER IN
      } else {
        try {
          final userCrenditial = await _firebase.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
          print(userCrenditial);

          final storageReF = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCrenditial.user!.uid}.jpg');

          await storageReF.putFile(_selectedImage!);
          final imageUrl = await storageReF.getDownloadURL();
          print("link ${imageUrl}");
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCrenditial.user!.uid)
              .set({
            'username': _usernameController.text, // Save username
            'email': _emailController.text,
            'image_url': imageUrl,
          });

          print("finish put collection");
        } on FirebaseAuthException catch (error) {
          if (error.code == 'email-already-in-use') {
            // You can handle specific actions here if needed
          }

          ScaffoldMessenger.of(context)
              .clearSnackBars(); // Clears any existing snack bars that are displayed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ??
                  'Authentication failed.'), // Displays the error message from Firebase or a default message
            ), // SnackBar
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign form key to the form widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              if (!_isLogin) // Only show username input in sign-up mode
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a username";
                    }
                    if (value.length < 4) {
                      return "Username must be at least 4 characters long";
                    }
                    return null;
                  },
                ),

              SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an email address";
                  }
                  if (!_emailController.text.contains('@')) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (!_isLogin)
                AddImageButton(
                  onPickImage: (File img) {
                    _selectedImage = img;
                  },
                ),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // foreground color
                ), // Call the form submission logic
                child: Text(_isLogin ? "Login" : "Sign Up"),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // Toggle between login and sign-up
                  });
                },
                child: Text(_isLogin
                    ? "Create an account"
                    : "I already have an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
