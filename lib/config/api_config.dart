class ApiConfig {
  static const String devUrl = 'http://127.0.0.1:8000/api';
  static const String prodUrl = 'https://golivreur.free.nf/api';

  static const bool isProd = true;

  static String get baseUrl => isProd ? prodUrl : devUrl;
}