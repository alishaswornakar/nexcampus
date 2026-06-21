import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// EMAIL/PASSWORD SIGN UP
  Future<bool> signUp(
    String email,
    String password,
    String fullName,
    String rollNumber,
    String department,
    String semester,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'rollNumber': rollNumber,
          'department': department,
          'semester': semester,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign Up Error: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Sign Up Error: $e");
      return false;
    }
  }

  /// EMAIL/PASSWORD LOGIN
  Future<bool> signIn(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Error: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    }
  }

  /// GOOGLE SIGN IN
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Sign Out Error: $e");
    }
  }

  /// CURRENT USER
  User? get currentUser => _auth.currentUser;
}