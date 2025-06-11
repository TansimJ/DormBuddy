import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //Firebase Auth
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //firestore INstance
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lazy getter for Firebase Auth
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Lazy getter for Firestore
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  //function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user!.updateDisplayName(name.trim());

      print("Saving user data to Firestore...");

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.trim(),
        'username': username.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User data saved to Firestore successfully.");

      return null; // ✅ Registration and Firestore write both succeeded
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth error: ${e.message}");
      return e.message ?? 'An auth error occurred';
    } catch (e) {
      print("Unexpected error: $e");
      return 'Something went wrong. Please try again.';
    }
  }



  //function to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      //fetch data from firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .get();
      return userDoc['role']; //return user role
       } catch (e) {
      return e.toString();
    }
  }
}