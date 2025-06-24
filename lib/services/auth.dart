import 'dart:developer' as developer;
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

      developer.log("Saving user data to Firestore...", name: 'AuthService');

// Write user data to Firestore
//some of this is for profile
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.trim(),
        'username': username.trim(),
        'phone': '',      // Add empty phone
        'address': '',    // Add empty address
        'bio': '',        // Add empty bio
        'createdAt': FieldValue.serverTimestamp(),
      });

      developer.log("User data saved to Firestore successfully.", name: 'AuthService');

      return null; // ✅ Registration and Firestore write both succeeded
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuth error: ${e.message}", name: 'AuthService', error: e);
      return e.message ?? 'An auth error occurred';
    } catch (e) {
      developer.log("Unexpected error: $e", name: 'AuthService', error: e);
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

  Future<void> addMissingFieldsToAllUsers() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in users.docs) {
      await doc.reference.set({
        'phone': doc['phone'] ?? 'Insert phone number',
        'address': doc['address'] ?? 'Insert address',
        'bio': doc['bio'] ?? 'Insert Bio',
      }, SetOptions(merge: true));
    }
  }
}