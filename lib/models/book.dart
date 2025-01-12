//book.dart
class Book {
  final int id;
  final String title;
  final String author;
  final String genre;
  final double price;
  final String? imageUrl;
  final String? description;
  final int stock;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.price,
    this.imageUrl,
    this.description,
    required this.stock,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      genre: json['genre'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      stock: json['stock'],
    );
  }
}
