//book_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl = 'haslife.uno';

  Future<List<Book>> fetchBooks() async {
    try {
      // Using HTTPS instead of HTTP
      final response = await http.get(Uri.http(baseUrl, '/getbooks.php'));

      // Logging the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return (data['data'] as List)
            .map((json) => Book.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load books. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load books: $e');
    }
  }
}
