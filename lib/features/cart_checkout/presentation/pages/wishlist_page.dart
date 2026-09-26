import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/notification_service.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../store/domain/entities/product_entity.dart';
import '../../../store/presentation/pages/product_detail_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  String _userId = 'fan-01';
  bool _notificationSent = false;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthBloc>().currentUser?.id ?? 'fan-01';
    context.read<CartBloc>().add(LoadWishlistEvent(_userId));
  }

  /// Simulate price drop check — fires notification for first item with discount
  Future<void> _checkPriceDrops(List<ProductEntity> wishlist) async {
    if (_notificationSent || wishlist.isEmpty) return;
    final discounted = wishlist.where(
      (p) => p.originalPrice != null && p.originalPrice! > p.price,
    );
    if (discounted.isNotEmpty) {
      final item = discounted.first;
      _notificationSent = true;
      await NotificationService.showPriceDropAlert(
        productName: item.name,
        newPrice: item.price,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded && state.wishlist.isNotEmpty) {
          _checkPriceDrops(state.wishlist);
        }
      },
      builder: (context, state) {
        final wishlist =
            state is CartLoaded ? state.wishlist : <ProductEntity>[];
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Saved Wishlist',
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
          IconButton(
            icon: const Icon(Iconsax.shopping_bag),
            tooltip: 'Go to Cart',
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
          body: Builder(
            builder: (context) {
              if (wishlist.isEmpty) {
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
                        Iconsax.heart,
                        size: 64,
                        color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Wishlist is Empty',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore exclusive anime katanas, figures, apparel and tap the heart icon to save for later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SkewedButton(
                      text: 'Explore Merch Catalog',
                      icon: Iconsax.shop,
                      height: 52,
                      fontSize: 13,
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/store'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: wishlist.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = wishlist[index];
              return _buildWishlistItem(context, product, isDark);
            },
          );
        },
      ),
        );
      },
    );
  }

  Widget _buildWishlistItem(BuildContext context, ProductEntity product, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Iconsax.gallery_slash),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.hasDiscount)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Price Dropped by \$${(product.originalPrice! - product.price).toStringAsFixed(0)}!',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.darkAccentGold : AppColors.lightAccentGold,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error, size: 20),
                tooltip: 'Remove',
                onPressed: () {
                  context.read<CartBloc>().add(
                        ToggleWishlistEvent(
                          userId: _userId,
                          productId: product.id,
                        ),
                      );
                },
              ),
              IconButton(
                icon: Icon(
                  Iconsax.shopping_cart,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                  size: 20,
                ),
                tooltip: 'Move to Cart',
                onPressed: () {
                  context.read<CartBloc>().add(
                        AddToCartEvent(
                          product: product,
                          quantity: 1,
                          variant: 'Standard',
                        ),
                      );
                  context.read<CartBloc>().add(
                        ToggleWishlistEvent(
                          userId: _userId,
                          productId: product.id,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Moved ${product.name} to Cart!'),
                      backgroundColor: AppColors.success,
                    ),
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


