import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccount {
  final String name;
  final String email;
  final String phone;
  final String passHash;
  String address;

  UserAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.passHash,
    this.address = '',
  });

  factory UserAccount.fromJson(Map<String, dynamic> j) => UserAccount(
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        passHash: j['passHash'] as String,
        address: (j['address'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'passHash': passHash,
        'address': address,
      };

  UserAccount copyWith({String? name, String? phone, String? address}) =>
      UserAccount(
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        passHash: passHash,
        address: address ?? this.address,
      );

  String get firstName => name.trim().split(' ').first;
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  static const _accountsKey = 'accounts_v1';
  static const _sessionKey = 'session_email';
  static const _onboardKey = 'onboarding_seen';

  final Map<String, UserAccount> _accounts = {};
  String? _sessionEmail;
  bool onboardingSeen = false;

  UserAccount? get user =>
      _sessionEmail == null ? null : _accounts[_sessionEmail];
  bool get loggedIn => user != null;

  static String hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    onboardingSeen = prefs.getBool(_onboardKey) ?? false;
    _sessionEmail = prefs.getString(_sessionKey);
    final raw = prefs.getString(_accountsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          final a = UserAccount.fromJson(e as Map<String, dynamic>);
          _accounts[a.email] = a;
        }
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _accountsKey, jsonEncode(_accounts.values.map((e) => e.toJson()).toList()));
    if (_sessionEmail == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, _sessionEmail!);
    }
  }

  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardKey, true);
  }

  bool emailTaken(String email) => _accounts.containsKey(email.trim().toLowerCase());

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    _accounts[e] = UserAccount(
      name: name.trim(),
      email: e,
      phone: phone.trim(),
      passHash: hash(password),
    );
    _sessionEmail = e;
    await _persist();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final a = _accounts[email.trim().toLowerCase()];
    if (a == null || a.passHash != hash(password)) return false;
    _sessionEmail = a.email;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _sessionEmail = null;
    await _persist();
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone, String? address}) async {
    final u = user;
    if (u == null) return;
    _accounts[u.email] = u.copyWith(name: name, phone: phone, address: address);
    await _persist();
    notifyListeners();
  }

  static String generateOtp() {
    final r = Random.secure();
    return List.generate(6, (_) => r.nextInt(10)).join();
  }
}
