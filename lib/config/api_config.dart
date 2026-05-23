import 'package:flutter/foundation.dart';

class ApiConfig {
  // Pour le Web local : 127.0.0.1 ou localhost fonctionne très bien
  // Pour un Émulateur Android : 127.0.0.1 pointe sur l'émulateur lui-même, pas votre PC. 
  // Il faut utiliser 10.0.2.2 pour qu'Android trouve votre Laravel.
  static String get devUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api'; // Adresse spéciale pour émulateur Android
    }
  }

  static const String prodUrl = 'https://golivreur.free.nf/api';
//----------------------------------------------
// Passez à 'true' pour la production et 'false' pour le développement local en commentant/décommentant les lignes suivantes  
//----------------------------------------------
  // Passez à 'false' pour le développement local
  //static const bool isProd = false; 

  // Passez à 'true' pour la production
  static const bool isProd = true; 


  static String get baseUrl => isProd ? prodUrl : devUrl;
}