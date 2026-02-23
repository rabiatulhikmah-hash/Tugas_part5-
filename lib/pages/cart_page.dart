import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Kosongkan Cart?'),
                            content:
                                const Text('Hapus semua item dari cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cart kamu masih kosong',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Lanjut Belanja'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.itemsList[index];
                    final product = cartItem.product;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Emoji
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.category,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(product.price),
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            cart.decreaseQuantity(product.id),
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        color: Colors.blue.shade700,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            cart.increaseQuantity(product.id),
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        color: Colors.blue.shade700,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Delete + subtotal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeItem(product.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('${product.name} dihapus'),
                                        duration:
                                            const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                                Text(
                                  _formatPrice(cartItem.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${cart.totalQuantity} item',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _formatPrice(cart.totalPrice),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Checkout →',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}