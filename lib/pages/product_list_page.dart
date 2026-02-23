import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // ── State ──────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // ── Data ───────────────────────────────────────────────────────────────────
  final List<Product> _allProducts = [
    Product(
      id: '1',
      name: 'Laptop Gaming',
      price: 15000000,
      emoji: '💻',
      description: 'Laptop gaming performa tinggi',
      category: 'Laptop',
    ),
    Product(
      id: '2',
      name: 'Smartphone Pro',
      price: 8000000,
      emoji: '📱',
      description: 'Smartphone flagship terbaru',
      category: 'Phone',
    ),
    Product(
      id: '3',
      name: 'Wireless Headphones',
      price: 1500000,
      emoji: '🎧',
      description: 'Headphones noise-cancelling',
      category: 'Audio',
    ),
    Product(
      id: '4',
      name: 'Smart Watch',
      price: 3000000,
      emoji: '⌚',
      description: 'Smartwatch dengan health tracking',
      category: 'Wearable',
    ),
    Product(
      id: '5',
      name: 'Camera DSLR',
      price: 12000000,
      emoji: '📷',
      description: 'Kamera DSLR profesional',
      category: 'Camera',
    ),
    Product(
      id: '6',
      name: 'Tablet Pro',
      price: 7000000,
      emoji: '📟',
      description: 'Tablet untuk produktivitas',
      category: 'Tablet',
    ),
    Product(
      id: '7',
      name: 'Laptop Ultrabook',
      price: 18000000,
      emoji: '🖥️',
      description: 'Laptop tipis dan ringan',
      category: 'Laptop',
    ),
    Product(
      id: '8',
      name: 'Earbuds TWS',
      price: 800000,
      emoji: '🎵',
      description: 'True wireless stereo earbuds',
      category: 'Audio',
    ),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> get _categories {
    final cats = _allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Product> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ── Format harga ───────────────────────────────────────────────────────────
  String _formatPrice(double price) {
    // e.g. 15000000 → "Rp 15.000.000"
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart icon with badge
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Category Filter ──────────────────────────────────────────────
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              },
            ),
          ),

          // ── Result count ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} produk ditemukan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Product Grid ─────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade50,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        product.emoji,
                                        style:
                                            const TextStyle(fontSize: 64),
                                      ),
                                    ),
                                    // Category badge
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade700,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(product.price),
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context
                                            .read<CartModel>()
                                            .addItem(product);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.name} ditambahkan!'),
                                            duration:
                                                const Duration(seconds: 1),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 14),
                                      label: const Text('Add',
                                          style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}