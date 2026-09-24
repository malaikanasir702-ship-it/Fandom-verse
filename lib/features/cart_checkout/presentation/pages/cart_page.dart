import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'checkout_invoice_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const LoadCartEvent());
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.trash, color: AppColors.error),
            SizedBox(width: 8),
            Text('Empty Cart?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove all merchandise from your simulated cart?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<CartBloc>().add(const ClearCartEvent());
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCouponAppliedModal(String coupon, double savings, double newTotal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Icon(Iconsax.award, size: 48, color: AppColors.darkAccentGold),
              const SizedBox(height: 12),
              Text(
                'Coupon Code "$coupon" Applied!',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You saved \$${savings.toStringAsFixed(2)} on this simulated fandom order.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Order Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '\$${newTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Awesome, Continue',
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Simulated Cart',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Iconsax.trash, color: AppColors.error),
                  tooltip: 'Empty Cart',
                  onPressed: _showClearCartDialog,
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! CartLoaded || state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.shopping_bag,
                        size: 64,
                        color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Cart is Empty',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your favorite limited anime katanas, figures, and merchandise.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Browse Merch Store',
                      icon: Iconsax.shop,
                      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/store'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cartItems = state.items;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItemCard(context, item, isDark);
                  },
                ),
              ),

              // Bottom Order Summary Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coupon Simulator Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter code FANDOM10 or CON2025',
                                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                                prefixIcon: const Icon(Iconsax.discount_shape, size: 18),
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {
                              final code = _couponController.text.trim();
                              if (code.isNotEmpty) {
                                context.read<CartBloc>().add(ApplyCouponEvent(code));
                                if (code.toUpperCase() == 'FANDOM10' || code.toUpperCase() == 'CON2025') {
                                  final discount = code.toUpperCase() == 'FANDOM10' ? state.subtotal * 0.1 : state.subtotal * 0.15;
                                  _showCouponAppliedModal(code.toUpperCase(), discount, state.total - discount);
                                }
                              }
                            },
                            child: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cost Breakdown Rows
                      _buildCostRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}', isDark),
                      if (state.discountAmount > 0)
                        _buildCostRow(
                          'Coupon Discount (${state.appliedCoupon})',
                          '-\$${state.discountAmount.toStringAsFixed(2)}',
                          isDark,
                          isHighlight: true,
                        ),
                      _buildCostRow(
                        'Estimated Shipping',
                        state.shippingFee == 0 ? 'FREE' : '\$${state.shippingFee.toStringAsFixed(2)}',
                        isDark,
                        isFree: state.shippingFee == 0,
                      ),
                      _buildCostRow('Estimated Sales Tax (8%)', '\$${state.taxAmount.toStringAsFixed(2)}', isDark),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '\$${state.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkAccentGold : AppColors.lightAccentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Proceed to Checkout CTA
                      CustomButton(
                        text: 'Proceed to Simulated Checkout',
                        icon: Iconsax.lock,
                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CheckoutInvoicePage(
                                subtotal: state.subtotal,
                                shippingFee: state.shippingFee,
                                discountAmount: state.discountAmount,
                                taxAmount: state.taxAmount,
                                totalAmount: state.total,
                                appliedCoupon: state.appliedCoupon,
                              ),
                            ),
                          );
                        },
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

  Widget _buildCartItemCard(BuildContext context, CartItemEntity item, bool isDark) {
    return Dismissible(
      key: Key(item.cartId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<CartBloc>().add(RemoveCartItemEvent(item.cartId));
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.product.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Iconsax.gallery_slash),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Variant: ${item.selectedVariant}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.darkAccentGold : AppColors.lightAccentGold,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Stepper
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.read<CartBloc>().add(
                            UpdateQuantityEvent(cartId: item.cartId, delta: -1),
                          );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Iconsax.minus, size: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      context.read<CartBloc>().add(
                            UpdateQuantityEvent(cartId: item.cartId, delta: 1),
                          );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Iconsax.add, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, bool isDark, {bool isHighlight = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight
                  ? AppColors.success
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFree
                  ? AppColors.success
                  : (isHighlight
                      ? AppColors.success
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}


