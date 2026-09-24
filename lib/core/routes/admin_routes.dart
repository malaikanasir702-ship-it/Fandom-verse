import 'package:flutter/material.dart';

// Store & Cart Pages
import '../../features/store/presentation/pages/storefront_page.dart';
import '../../features/store/presentation/pages/product_detail_page.dart';
import '../../features/store/domain/entities/product_entity.dart';
import '../../features/cart_checkout/presentation/pages/cart_page.dart';
import '../../features/cart_checkout/presentation/pages/wishlist_page.dart';
import '../../features/cart_checkout/presentation/pages/checkout_invoice_page.dart';
import '../../features/cart_checkout/presentation/pages/order_success_page.dart';
import '../../features/cart_checkout/presentation/pages/order_history_page.dart';
import '../../features/cart_checkout/domain/entities/order_invoice_entity.dart';

// Admin Pages
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_content_page.dart';
import '../../features/admin/presentation/pages/admin_content_edit_page.dart';
import '../../features/admin/presentation/pages/admin_events_page.dart';
import '../../features/admin/presentation/pages/admin_event_edit_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/admin_product_edit_page.dart';
import '../../features/admin/presentation/pages/admin_users_categories_page.dart';

class AdminRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Store & Checkout
      case '/store':
        return MaterialPageRoute(builder: (_) => const StorefrontPage());

      case '/product-detail':
        final product = settings.arguments as ProductEntity;
        return MaterialPageRoute(builder: (_) => ProductDetailPage(product: product));

      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());

      case '/wishlist':
        return MaterialPageRoute(builder: (_) => const WishlistPage());

      case '/checkout-invoice':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => CheckoutInvoicePage(
            subtotal: (args['subtotal'] as num?)?.toDouble() ?? 0.0,
            shippingFee: (args['shippingFee'] as num?)?.toDouble() ?? 0.0,
            discountAmount: (args['discountAmount'] as num?)?.toDouble() ?? 0.0,
            taxAmount: (args['taxAmount'] as num?)?.toDouble() ?? 0.0,
            totalAmount: (args['totalAmount'] as num?)?.toDouble() ?? 0.0,
            appliedCoupon: args['appliedCoupon'] ?? '',
          ),
        );

      case '/order-success':
        final invoice = settings.arguments as OrderInvoiceEntity;
        return MaterialPageRoute(builder: (_) => OrderSuccessPage(invoice: invoice));

      case '/order-history':
        return MaterialPageRoute(builder: (_) => const OrderHistoryPage());

      // Admin Console
      case '/admin/dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case '/admin/content':
        return MaterialPageRoute(builder: (_) => const AdminContentPage());

      case '/admin/content-edit':
        final article = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => AdminContentEditPage(existingArticle: article));

      case '/admin/events':
        return MaterialPageRoute(builder: (_) => const AdminEventsPage());

      case '/admin/event-edit':
        final event = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => AdminEventEditPage(existingEvent: event));

      case '/admin/products':
        return MaterialPageRoute(builder: (_) => const AdminProductsPage());

      case '/admin/product-edit':
        final product = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => AdminProductEditPage(existingProduct: product));

      case '/admin/users-categories':
        return MaterialPageRoute(builder: (_) => const AdminUsersCategoriesPage());

      default:
        return null;
    }
  }
}
