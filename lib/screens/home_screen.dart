import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../book_service.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = '';
  String _selectedGenre = 'All';
  bool _sortByPriceDesc = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.fetchBooks();
      setState(() {
        _books = books;
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading books: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBooks = _books.where((book) {
        final matchesSearch =
            book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                book.author.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesGenre =
            _selectedGenre == 'All' || book.genre == _selectedGenre;
        return matchesSearch && matchesGenre;
      }).toList();

      if (_sortByPriceDesc) {
        _filteredBooks.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookstore'),
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return cart.items.length > 0
                        ? Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.items.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedGenre,
                          items: ['All', ..._books.map((b) => b.genre).toSet()]
                              .map((genre) => DropdownMenuItem(
                                    value: genre,
                                    child: Text(genre),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenre = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      TextButton.icon(
                        icon: Icon(_sortByPriceDesc
                            ? Icons.arrow_downward
                            : Icons.arrow_upward),
                        label: Text('Price'),
                        onPressed: () {
                          setState(() {
                            _sortByPriceDesc = !_sortByPriceDesc;
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return BookCard(book: book);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
