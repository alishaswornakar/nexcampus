// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   /// EMAIL/PASSWORD SIGN UP
//   Future<bool> signUp(
//     String email,
//     String password,
//     String fullName,
//     String rollNumber,
//     String department,
//     String semester,
//   ) async {
//     try {
//       final UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final User? user = userCredential.user;

//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'fullName': fullName,
//           'email': email,
//           'rollNumber': rollNumber,
//           'department': department,
//           'semester': semester,
//           'createdAt': FieldValue.serverTimestamp(),
//         });

//         return true;
//       }

//       return false;
//     } on FirebaseAuthException catch (e) {
//       debugPrint("Sign Up Error: ${e.message}");
//       return false;
//     } catch (e) {
//       debugPrint("Sign Up Error: $e");
//       return false;
//     }
//   }

//   /// EMAIL/PASSWORD LOGIN
//   Future<bool> signIn(
//     String email,
//     String password,
//   ) async {
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return true;
//     } on FirebaseAuthException catch (e) {
//       debugPrint("Login Error: ${e.message}");
//       return false;
//     } catch (e) {
//       debugPrint("Login Error: $e");
//       return false;
//     }
//   }

//   /// GOOGLE SIGN IN
//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser =
//           await _googleSignIn.signIn();

//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);

//       return userCredential.user;
//     } catch (e) {
//       debugPrint("Google Sign-In Error: $e");
//       return null;
//     }
//   }

//   /// SIGN OUT
//   Future<void> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await _auth.signOut();
//     } catch (e) {
//       debugPrint("Sign Out Error: $e");
//     }
//   }

//   /// CURRENT USER
//   User? get currentUser => _auth.currentUser;
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nexcampus_app/core/notifications/services/fcm_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // LOGIN
  // =========================
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FCMService.saveToken();
    FCMService.listenTokenRefresh();

    return credential;
  }

  // =========================
  // SIGNUP (EMAIL)
  // =========================
  Future<UserCredential> signup({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // =========================
  // CREATE USER PROFILE
  // =========================
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
    required String roll,
    required String department,
    required String semester,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'roll': roll,
      'department': department,
      'semester': semester,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await FCMService.saveToken();
    FCMService.listenTokenRefresh();
  }

  // =========================
  // GET USER ROLE
  // =========================
  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User document not found");
    }

    return (doc.data()?['role'] ?? '') as String;
  }

  // =========================
  // GOOGLE SIGN IN (NEW)
  // =========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();

        // If new user → create default profile
        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'fullName': user.displayName ?? '',
            'email': user.email ?? '',
            'role': 'student', // default role
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await FCMService.saveToken();
      FCMService.listenTokenRefresh();

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;

    // Remove this device's FCM token from the user's doc so the next
    // person who logs in on this device doesn't inherit push
    // notifications / token association from the previous account.
    if (uid != null) {
      try {
        await FCMService.clearToken(uid);
      } catch (_) {
        // Non-fatal — don't block sign-out if this fails.
      }
    }

    final googleSignIn = GoogleSignIn();

    // signOut() alone only clears the local session; it does NOT forget
    // which Google account was chosen. disconnect() revokes access and
    // clears the cached account so the account picker shows up again
    // next time, instead of silently re-signing the previous user in.
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.disconnect();
    }

    await _auth.signOut();
  }

  // =========================
  // CURRENT USER
  // =========================
  User? get currentUser => _auth.currentUser;
}
