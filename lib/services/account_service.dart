import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_bootstrap.dart';
import 'progress_store.dart';

enum AccountResult {
  ok,
  notConfigured,
  invalidUserId,
  invalidPin,
  userIdTaken,
  wrongCredentials,
  tooManyAttempts,
  network,
  noBackup,
  unknown,
}

/// Optional account (User ID + PIN) with cloud backup of progress.
///
/// Implemented on Firebase Authentication (email/password provider) by
/// mapping the User ID to an internal address; no real e-mail is collected.
class AccountService extends ChangeNotifier {
  AccountService(this._prefs);

  static const _kLastBackup = 'account.lastBackup';
  static const _domain = 'users.breathecare.app';
  static const _timeout = Duration(seconds: 20);

  final SharedPreferences _prefs;
  StreamSubscription<User?>? _authSub;
  bool busy = false;

  bool get available => FirebaseBootstrap.available;

  User? get _user => available ? FirebaseAuth.instance.currentUser : null;

  bool get signedIn => _user != null;

  String? get userId {
    final email = _user?.email;
    if (email == null) return null;
    return email.split('@').first;
  }

  DateTime? get lastBackup {
    final ms = _prefs.getInt(_kLastBackup);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void init() {
    if (!available) return;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  static final _idPattern = RegExp(r'^[a-z0-9_]{4,20}$');
  static final _pinPattern = RegExp(r'^\d{4,6}$');

  static bool isValidUserId(String id) => _idPattern.hasMatch(id.trim().toLowerCase());
  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin.trim());

  String _email(String id) => '${id.trim().toLowerCase()}@$_domain';

  // Firebase requires passwords of 6+ characters; the PIN is wrapped.
  String _password(String pin) => 'bc:${pin.trim()}:breathecare';

  Future<AccountResult> _run(Future<void> Function() action) async {
    if (!available) return AccountResult.notConfigured;
    busy = true;
    notifyListeners();
    try {
      await action().timeout(_timeout);
      return AccountResult.ok;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return AccountResult.userIdTaken;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
          return AccountResult.wrongCredentials;
        case 'too-many-requests':
          return AccountResult.tooManyAttempts;
        case 'network-request-failed':
          return AccountResult.network;
        default:
          debugPrint('Auth error: ${e.code}');
          return AccountResult.unknown;
      }
    } on _NoBackup {
      return AccountResult.noBackup;
    } on TimeoutException {
      return AccountResult.network;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code}');
      return e.code == 'unavailable' ? AccountResult.network : AccountResult.unknown;
    } catch (e) {
      debugPrint('Account error: $e');
      return AccountResult.unknown;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  AccountResult? _validate(String id, String pin) {
    if (!isValidUserId(id)) return AccountResult.invalidUserId;
    if (!isValidPin(pin)) return AccountResult.invalidPin;
    return null;
  }

  Future<AccountResult> createAccount(String id, String pin) async =>
      _validate(id, pin) ??
      await _run(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email(id), password: _password(pin)),
      );

  Future<AccountResult> signIn(String id, String pin) async =>
      _validate(id, pin) ??
      await _run(() => FirebaseAuth.instance.signInWithEmailAndPassword(email: _email(id), password: _password(pin)));

  Future<void> signOut() async {
    if (!available) return;
    await FirebaseAuth.instance.signOut();
    await _prefs.remove(_kLastBackup);
    notifyListeners();
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) => FirebaseFirestore.instance.collection('backups').doc(uid);

  Future<AccountResult> backup(ProgressStore store) async {
    final uid = _user?.uid;
    if (uid == null) return AccountResult.wrongCredentials;
    return _run(() async {
      await _doc(uid).set({'version': 1, 'data': store.exportData(), 'updatedAt': FieldValue.serverTimestamp()});
      await _prefs.setInt(_kLastBackup, DateTime.now().millisecondsSinceEpoch);
    });
  }

  Future<AccountResult> restore(ProgressStore store) async {
    final uid = _user?.uid;
    if (uid == null) return AccountResult.wrongCredentials;
    return _run(() async {
      final snap = await _doc(uid).get(const GetOptions(source: Source.server));
      final data = snap.data()?['data'];
      if (data is! Map) throw _NoBackup();
      await store.importData(Map<String, dynamic>.from(data));
    });
  }

  /// Removes the cloud backup and the account itself, then signs out.
  Future<void> deleteCloudData() async {
    final user = _user;
    if (user == null) return;
    try {
      await _doc(user.uid).delete().timeout(_timeout);
    } catch (e) {
      debugPrint('Could not delete backup: $e');
    }
    try {
      await user.delete().timeout(_timeout);
    } catch (e) {
      debugPrint('Could not delete account: $e');
    }
    await signOut();
  }
}

class _NoBackup implements Exception {}
