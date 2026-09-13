import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _setOnlineStatus(true);
      return null;
    } on FirebaseAuthException catch(e) {
      return _mapAuthError(e);
    } catch(e) {
      return 'Something went wrong. Please check your internet connection.';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);

      await _firestore
           .collection(AppConstants.usersCollection)
           .doc(credential.user!.uid)
            .set({
           'name': name,
           'email': email,
           'photoUrl': null,
           'isOnline': true,
           'lastSeen': DateTime.now().toIso8601String(),
      });

      return null;
    } on FirebaseAuthException catch(e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'Something went wrong. Please check your internet connection.';
    }
  }

  Future<void> logout() async {
    await _setOnlineStatus(false);
    await _auth.signOut();
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if(uid == null) return;
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}