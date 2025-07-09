import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/user_model.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final Map<String, bool> _initialBadges = {
    'lock': false,
    'banned': false,
    'target': false,
    'eyes': false,
    'fact_check':false,
    'key': false,
    'private_detective': false,
    'floppy_disk': false,
    'earth': false,
    'compass': false,
  };

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserData(cred.user!.uid);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        badges: Map.from(_initialBadges),
      );

      await _db.collection("users").doc(_user!.id).set(_user!.toMap());
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      final doc = await _db.collection("users").doc(userCred.user!.uid).get();
      if (!doc.exists) {
        _user = UserModel(
          id: userCred.user!.uid,
          name: userCred.user!.displayName ?? 'Utente',
          email: userCred.user!.email!,
          badges: Map.from(_initialBadges),
        );
        await _db.collection("users").doc(_user!.id).set(_user!.toMap());
      } else {
        await _fetchUserData(userCred.user!.uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (doc.exists) {
      _user = UserModel.fromMap(uid, doc.data()!);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }
}
