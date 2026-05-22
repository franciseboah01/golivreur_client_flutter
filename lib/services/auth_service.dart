import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuth = false;
  String? _token;
  String? _role;
  int? _userId;
  String? _nom;
  String? _prenom;
  String? _telephone;

  bool get isAuth => _isAuth;
  String? get token => _token;
  String? get role => _role;
  int? get userId => _userId;
  String? get nom => _nom;
  String? get prenom => _prenom;
  String? get telephone => _telephone;

  Future<bool> connecter(String telephone, String password) async {
    try {
      final response = await ApiService.post('/connecter', {
        'telephone': telephone,
        'password': password,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _role = data['utilisateur']['role'];
        _userId = data['utilisateur']['id'];
        _nom = data['utilisateur']['nom'];
        _prenom = data['utilisateur']['prenom'];
        _telephone = data['utilisateur']['telephone'];
        _isAuth = true;
        await _saveSession();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Inscription avec support optionnel du zoneId
  Future<dynamic> inscrireAvecMessage(
    String nom,
    String prenom,
    String telephone,
    String password,
    String role, {
    int? zoneId,
  }) async {
    try {
      final body = <String, dynamic>{
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'password': password,
        'role': role,
      };
      if (zoneId != null) body['zone_id'] = zoneId;

      final response = await ApiService.post('/inscrire', body);
      if (response.statusCode == 201) return true;
      final responseBody = jsonDecode(response.body);
      if (responseBody['erreur'] != null) return responseBody['erreur'].toString();
      if (responseBody['message'] != null) return responseBody['message'].toString();
      return 'Erreur ${response.statusCode}';
    } catch (e) {
      return 'Erreur réseau, veuillez réessayer';
    }
  }

  Future<void> deconnecter() async {
    try {
      await ApiService.post('/deconnecter', {});
    } catch (_) {}
    _token = null;
    _role = null;
    _userId = null;
    _nom = null;
    _prenom = null;
    _telephone = null;
    _isAuth = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// Reconnexion automatique depuis SharedPreferences.
  /// /profil étant commenté côté API, on restaure depuis le cache local.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    if (savedToken == null) return;

    _token = savedToken;
    _role = prefs.getString('role');
    _userId = prefs.getInt('user_id');
    _nom = prefs.getString('nom');
    _prenom = prefs.getString('prenom');
    _telephone = prefs.getString('telephone');
    _isAuth = true;
    notifyListeners();

    // À activer dès que /profil sera décommenté côté Laravel :
    //
    // try {
    //   final response = await ApiService.get('/profil');
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //     _role      = data['role'];
    //     _userId    = data['id'];
    //     _nom       = data['nom'];
    //     _prenom    = data['prenom'];
    //     _telephone = data['telephone'];
    //     notifyListeners();
    //   } else {
    //     await deconnecter();
    //   }
    // } catch (_) {
    //   await deconnecter();
    // }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('role', _role!);
    if (_userId != null) await prefs.setInt('user_id', _userId!);
    if (_nom != null) await prefs.setString('nom', _nom!);
    if (_prenom != null) await prefs.setString('prenom', _prenom!);
    if (_telephone != null) await prefs.setString('telephone', _telephone!);
  }
}