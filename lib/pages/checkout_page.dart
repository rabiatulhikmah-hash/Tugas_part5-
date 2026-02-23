import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  // State
  String _paymentMethod = 'Transfer Bank';
  bool _isOrdering = false;

  final List<String> _paymentMethods = [
    'Transfer Bank',
    'QRIS',
    'COD (Bayar di Tempat)',
    'Kartu Kredit',
  ];

  final Map<String, String> _paymentIcons = {
    'Transfer Bank': '🏦',
    'QRIS': '📲',
    'COD (Bayar di Tempat)': '💵',
    'Kartu Kredit': '💳',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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

  void _placeOrder(CartModel cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isOrdering = true);

    // Simulate processing
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final customerName = _nameController.text.trim();
    final selectedPayment = _paymentMethod;
    final paymentIcon = _paymentIcons[selectedPayment] ?? '💳';

    cart.clear();
    setState(() => _isOrdering = false);

    // Show beautiful success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Party popper emoji besar
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Halo $customerName, pesananmu sedang diproses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Metode: $paymentIcon $selectedPayment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // tutup dialog
                    // Balik ke product list
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    'Kembali Belanja',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          const double shippingCost = 25000;
          final double subtotal = cart.totalPrice;
          final double total = subtotal + shippingCost;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Order Summary ──────────────────────────────────────────
                _SectionCard(
                  title: '🧾 Ringkasan Pesanan',
                  child: Column(
                    children: [
                      ...cart.itemsList.map((item) =>
                          _OrderItem(item: item, formatPrice: _formatPrice)),
                      const Divider(height: 20),
                      _PriceRow(
                          label: 'Subtotal (${cart.totalQuantity} item)',
                          value: _formatPrice(subtotal)),
                      const SizedBox(height: 4),
                      _PriceRow(
                          label: 'Ongkos Kirim',
                          value: _formatPrice(shippingCost)),
                      const Divider(height: 16),
                      _PriceRow(
                        label: 'Total',
                        value: _formatPrice(total),
                        isBold: true,
                        valueColor: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Shipping Info ──────────────────────────────────────────
                _SectionCard(
                  title: '📦 Info Pengiriman',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Penerima *',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Nama tidak boleh kosong'
                                : null,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          hintText: '08xx-xxxx-xxxx',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor HP tidak boleh kosong';
                          }
                          if (v.trim().length < 10) {
                            return 'Nomor HP tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap *',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          hintText: 'Jalan, No. Rumah, RT/RW, Kelurahan...',
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Alamat tidak boleh kosong'
                                : null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          hintText: 'Misal: titip ke satpam jika tidak ada...',
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Payment Method ─────────────────────────────────────────
                _SectionCard(
                  title: '💳 Metode Pembayaran',
                  child: Column(
                    children: _paymentMethods.map((method) {
                      final isSelected = method == _paymentMethod;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _paymentMethod = method),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue.shade400
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _paymentIcons[method] ?? '💳',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  method,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue.shade700
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle,
                                    color: Colors.blue.shade600, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Order Button ───────────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isOrdering ? null : () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isOrdering
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Memproses pesanan...'),
                            ],
                          )
                        : Text(
                            'Pesan Sekarang · ${_formatPrice(total)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final CartItem item;
  final String Function(double) formatPrice;

  const _OrderItem({required this.item, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${formatPrice(item.product.price)} × ${item.quantity}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatPrice(item.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
