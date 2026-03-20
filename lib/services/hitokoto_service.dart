import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/hitokoto_quote.dart';

class HitokotoService {
  HitokotoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _baseUri = Uri.parse('https://v1.hitokoto.cn/');
  static const Map<String, String> _headers = {
    'User-Agent': 'flutter-study-app/1.0',
    'Accept': 'application/json,text/plain,*/*',
  };

  Future<HitokotoQuote> fetchRandomFromAll() async {
    return _fetchJson(_baseUri);
  }

  Future<HitokotoQuote> fetchManga() async {
    return _fetchJson(_baseUri.replace(queryParameters: {'c': 'b'}));
  }

  Future<String> fetchNetworkText() async {
    final uri = _baseUri.replace(
      queryParameters: {'c': 'f', 'encode': 'text'},
    );
    debugPrint('[Hitokoto] Request URL: $uri');
    final response = await _client.get(uri, headers: _headers);
    _ensureSuccess(response);
    final text = utf8.decode(response.bodyBytes).trim();
    debugPrint('[Hitokoto] Response: $text');
    return text;
  }

  Future<HitokotoQuote> _fetchJson(Uri uri) async {
    debugPrint('[Hitokoto] Request URL: $uri');
    final response = await _client.get(uri, headers: _headers);
    _ensureSuccess(response);
    final raw = utf8.decode(response.bodyBytes);
    debugPrint('[Hitokoto] Response: $raw');
    final data = jsonDecode(raw);
    return HitokotoQuote.fromJson(data as Map<String, dynamic>);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('接口请求失败（HTTP ${response.statusCode}）');
  }
}
