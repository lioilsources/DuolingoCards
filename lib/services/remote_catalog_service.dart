import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/cdn_config.dart';
import '../models/store_catalog.dart';

/// Fetches the remote catalog (`docs/catalog.json` on the CDN) and keeps the
/// last good copy in SharedPreferences.
///
/// Resolution is network → cache → nothing; the caller merges the result over
/// the bundled catalog, which is the final fallback (see
/// [StoreCatalog.merge]). A response that does not parse never replaces the
/// cache, so one bad publish cannot empty the store on every device.
class RemoteCatalogService {
  RemoteCatalogService({
    http.Client? client,
    Uri? url,
    this.timeout = const Duration(seconds: 4),
  }) : _client = client,
       url = url ?? Uri.parse('$kCdnBaseUrl/catalog.json');

  final http.Client? _client;
  final Uri url;
  final Duration timeout;

  static const String cacheKey = 'remote_catalog_v1';

  /// The cached catalog, or null when nothing (valid) was ever cached.
  StoreCatalog? cached(SharedPreferences prefs) {
    final raw = prefs.getString(cacheKey);
    return raw == null ? null : _parse(raw);
  }

  /// Fetch a fresh catalog and cache it. Null on any failure — offline, a
  /// timeout, a non-200, or a body that is not a catalog.
  Future<StoreCatalog?> fetch(SharedPreferences prefs) async {
    try {
      final client = _client;
      final response = await (client != null ? client.get(url) : http.get(url))
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      final body = utf8.decode(response.bodyBytes);
      final catalog = _parse(body);
      if (catalog == null) return null;
      await prefs.setString(cacheKey, body);
      return catalog;
    } catch (e) {
      debugPrint('Remote catalog fetch failed: $e');
      return null;
    }
  }

  /// Fresh catalog if the network answers in time, else the cached one.
  Future<StoreCatalog?> load(SharedPreferences prefs) async =>
      await fetch(prefs) ?? cached(prefs);

  static StoreCatalog? _parse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      // An empty document is a broken publish, not "nothing is for sale".
      if (json['free'] is! List || json['products'] is! List) return null;
      return StoreCatalog.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
