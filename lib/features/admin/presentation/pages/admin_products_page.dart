import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_modals.dart';
import 'admin_product_edit_page.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: const Text(
          'Store Inventory Manager',
          style: TextStyle(
            color: AppColors.adminLightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.adminLightTextPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.success,
        icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminProductEditPage(),
            ),
          );
        },
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.success));
          }

          final allProducts = state is AdminStatsLoaded ? state.products : [];
          final query = _searchController.text.toLowerCase().trim();

          final filtered = allProducts.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            final cat = (p['category'] ?? '').toString().toLowerCase();
            return query.isEmpty || name.contains(query) || cat.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search products by title or category...',
                    hintStyle: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 12),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.adminLightTextSecondary, size: 18),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Items Listed in Store',
                      style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found.',
                          style: TextStyle(color: AppColors.adminLightTextSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return _buildProductTile(context, product);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Map<String, dynamic> product) {
    final stock = (product['stock_count'] as num?)?.toInt() ?? 0;
    final isLowStock = stock <= 5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminLightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppDisplayImage(
              pathOrUrl: product['image_url'] ?? '',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (product['category'] ?? 'MERCH').toString().toUpperCase(),
                        style: const TextStyle(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        AdminModals.showFastStockUpdateDialog(
                          context: context,
                          productName: product['name'] ?? '',
                          currentStock: stock,
                          onStockUpdated: (newStock) {
                            context.read<AdminBloc>().add(
                                  UpdateStockQuickEvent(product['product_id'], newStock),
                                );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLowStock ? AppColors.error.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isLowStock ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Stock: $stock',
                              style: TextStyle(
                                color: isLowStock ? AppColors.error : AppColors.adminLightTextSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Iconsax.edit_2, size: 8, color: AppColors.adminLightTextSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${((product['price'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFD97706), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit_2, color: Color(0xFF2563EB), size: 18),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminProductEditPage(existingProduct: product),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error, size: 18),
                onPressed: () {
                  AdminModals.showDeleteBarrierDialog(
                    context: context,
                    itemName: product['name'] ?? 'Product',
                    onConfirmed: () {
                      context.read<AdminBloc>().add(DeleteProductEvent(product['product_id']));
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
