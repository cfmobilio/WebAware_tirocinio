import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/user_model.dart';
import '../../../ui/initialtest/viewmodel/initial_test_viewmodel.dart';


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
    print('🚀 INIZIO REGISTRAZIONE');
    print('👤 Nome: $name, Email: $email');

    _setLoading(true);
    _errorMessage = null;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Utente Firebase creato con UID: ${cred.user!.uid}');

      // Recupera il livello salvato temporaneamente dal quiz
      String? tempLevel = InitialTestViewModel.getTempLevel();
      print('🔍 Livello temporaneo recuperato: $tempLevel');

      if (tempLevel == null) {
        print('⚠️ ATTENZIONE: Nessun livello temporaneo trovato!');
      }

      _user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        badges: Map.from(_initialBadges),
        livello: tempLevel,
      );

      print('📦 UserModel creato:');
      print('   - ID: ${_user!.id}');
      print('   - Nome: ${_user!.name}');
      print('   - Email: ${_user!.email}');
      print('   - Livello: ${_user!.livello}');

      final userData = _user!.toMap();
      print('🗂️ Dati da salvare in Firebase: $userData');

      await _db.collection("users").doc(_user!.id).set(userData);
      print('💾 Dati salvati in Firebase');

      // Verifica che sia stato salvato
      final docCheck = await _db.collection("users").doc(_user!.id).get();
      if (docCheck.exists) {
        final savedData = docCheck.data()!;
        print('✅ Verifica salvataggio: ${savedData['livello']}');
      }

      // Pulisci il livello temporaneo dopo averlo salvato
      InitialTestViewModel.clearTempLevel();
      print('🧹 Livello temporaneo pulito');

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ ERRORE REGISTRAZIONE: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

// AGGIUNGI QUESTO IMPORT IN CIMA AL FILE AuthViewModel:
// import '../../initialtest/viewmodel/initial_test_viewmodel.dart';
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
      print('🔍 Google Sign-In completato per UID: ${userCred.user!.uid}');

      final doc = await _db.collection("users").doc(userCred.user!.uid).get();
      if (!doc.exists) {
        print('👤 Nuovo utente Google - creazione profilo');

        // ⭐ RECUPERA IL LIVELLO TEMPORANEO DAL QUIZ
        String? tempLevel = InitialTestViewModel.getTempLevel();
        print('🔍 Livello temporaneo per Google user: $tempLevel');

        _user = UserModel(
          id: userCred.user!.uid,
          name: userCred.user!.displayName ?? 'Utente',
          email: userCred.user!.email!,
          badges: Map.from(_initialBadges),
          livello: tempLevel, // ⭐ AGGIUNGI IL LIVELLO QUI
        );

        print('📦 Dati Google user da salvare: ${_user!.toMap()}');
        await _db.collection("users").doc(_user!.id).set(_user!.toMap());

        // ⭐ PULISCI IL LIVELLO TEMPORANEO
        InitialTestViewModel.clearTempLevel();
        print('✅ Livello temporaneo applicato e pulito');

      } else {
        print('👤 Utente Google esistente - caricamento dati');
        await _fetchUserData(userCred.user!.uid);
      }
    } catch (e) {
      print('❌ Errore Google Sign-In: $e');
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  String? get currentUserId => _user?.id;

  Future<void> updateUserLevel(String level) async {
    if (_user == null) return;

    try {
      await _db.collection("users").doc(_user!.id).update({'livello': level});
      await _fetchUserData(_user!.id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
