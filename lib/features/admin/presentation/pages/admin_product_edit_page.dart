import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminProductEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingProduct;

  const AdminProductEditPage({super.key, this.existingProduct});

  @override
  State<AdminProductEditPage> createState() => _AdminProductEditPageState();
}

class _AdminProductEditPageState extends State<AdminProductEditPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _imageController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Apparel';
  bool _isFeatured = false;

  final List<String> _categories = [
    'Apparel',
    'Action Figures',
    'Manga/Comics',
    'Digital Collectibles',
    'Replica Props',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p['name'] ?? '';
      _priceController.text = (p['price'] ?? 0.0).toString();
      _originalPriceController.text = (p['original_price'] ?? '').toString();
      _stockController.text = (p['stock_count'] ?? 10).toString();
      _imageController.text = p['image_url'] ?? '';
      _descController.text = p['description'] ?? '';
      _category = p['category'] ?? 'Apparel';
      _isFeatured = p['is_featured'] == 1;
    } else {
      _imageController.text = 'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=600';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Merchandise' : 'List New Merchandise',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Product Title',
              hintText: 'e.g. Chrono Blade Neon Katana (Replica 1:1)',
            ),
            const SizedBox(height: 14),

            const Text(
              'Store Category',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                dropdownColor: const Color(0xFF131722),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _priceController,
                    label: 'Price (\$ USD)',
                    hintText: '89.99',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _originalPriceController,
                    label: 'Original Price (\$)',
                    hintText: '110.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stockController,
                    label: 'Available Stock Units',
                    hintText: '15',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _imageController,
              label: 'High-Res Product Image URL',
              hintText: 'https://images.unsplash.com/...',
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _descController,
              label: 'Merchandise Description & Collector Specs',
              hintText: 'Dimensions, materials, official licensing certifications...',
              maxLines: 4,
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured Frontpage Drop', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: const Text('Showcase on Storefront deal carousel', style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: _isFeatured,
                activeThumbColor: AppColors.success,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
            ),
            const SizedBox(height: 24),

            SkewedButton(
              text: isEdit ? 'Save Product Changes' : 'List Item on Store Catalog',
              icon: Iconsax.box,
              height: 52,
              fontSize: 13,
              backgroundColor: AppColors.success,
              onPressed: () {
                final name = _nameController.text.trim();
                final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid product title and price.')),
                  );
                  return;
                }

                final origPrice = double.tryParse(_originalPriceController.text.trim());
                final stock = int.tryParse(_stockController.text.trim()) ?? 10;

                final productData = {
                  'product_id': isEdit
                      ? widget.existingProduct!['product_id']
                      : 'prod-${DateTime.now().millisecondsSinceEpoch}',
                  'name': name,
                  'category': _category,
                  'price': price,
                  'original_price': origPrice,
                  'stock_count': stock,
                  'image_url': _imageController.text.trim(),
                  'description': _descController.text.trim(),
                  'rating': 4.9,
                  'is_featured': _isFeatured ? 1 : 0,
                };

                context.read<AdminBloc>().add(
                      CreateOrUpdateProductEvent(productData, isEdit: isEdit),
                    );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Product updated!' : 'Product listed!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

