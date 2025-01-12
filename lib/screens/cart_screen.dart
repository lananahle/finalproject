import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/currency_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _discountController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text('Your cart is empty',
                        style: Theme.of(context).textTheme.titleLarge))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.toList()[i];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: FittedBox(
                                child: Text('${item.quantity}x'),
                              ),
                            ),
                            title: Text(item.book.title),
                            subtitle: Text(
                                'Total: ${currencyProvider.formatPrice(item.book.price * item.quantity)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () =>
                                      cart.decreaseQuantity(item.book.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => cart.addItem(item.book),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      cart.removeItem(item.book.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  if (cart.items.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _discountController,
                              decoration: InputDecoration(
                                labelText: 'Discount Code',
                                errorText: _errorMessage,
                                suffixIcon: cart.appliedDiscountCode != null
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          cart.removeDiscountCode();
                                          _discountController.clear();
                                          setState(() => _errorMessage = null);
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: cart.appliedDiscountCode == null
                                ? () {
                                    if (cart.applyDiscountCode(
                                        _discountController.text)) {
                                      setState(() => _errorMessage = null);
                                    } else {
                                      setState(() => _errorMessage =
                                          'Invalid discount code');
                                    }
                                  }
                                : null,
                            child: Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: TextStyle(fontSize: 16)),
                      Text(currencyProvider.formatPrice(cart.subtotal)),
                    ],
                  ),
                  if (cart.discount > 0) ...[
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount (${cart.appliedDiscountCode})',
                            style:
                                TextStyle(fontSize: 16, color: Colors.green)),
                        Text(
                          '-${currencyProvider.formatPrice(cart.discount)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        currencyProvider.formatPrice(cart.totalAmount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text('PROCEED TO CHECKOUT'),
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
