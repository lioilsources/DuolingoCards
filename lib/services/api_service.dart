import 'package:dio/dio.dart';
import '../models/catalog.dart';
import '../models/deck.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ));

  Future<Catalog> getCatalog() async {
    try {
      final response = await _dio.get('/api/catalog');
      return Catalog.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Failed to load catalog: ${e.message}');
    }
  }

  Future<DeckPreview> getDeckPreview(String deckId) async {
    try {
      final response = await _dio.get('/api/decks/$deckId/preview');
      return DeckPreview.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Failed to load deck preview: ${e.message}');
    }
  }

  Future<Deck> getDeck(String deckId) async {
    try {
      final response = await _dio.get('/api/decks/$deckId');
      return Deck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Failed to load deck: ${e.message}');
    }
  }

  Future<Deck> downloadDeck(String deckId, {String? receiptData}) async {
    try {
      final response = await _dio.post(
        '/api/decks/$deckId/download',
        data: receiptData != null ? {'receipt': receiptData} : null,
      );
      return Deck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Failed to download deck: ${e.message}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
