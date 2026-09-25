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

import '../di/service_locator.dart';
import '../pages/access_denied_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class AdminRoutes {
  static Route<dynamic> guardAdminRoute(Widget page) {
    if (!sl.isRegistered<AuthBloc>()) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }
    final authBloc = sl<AuthBloc>();
    final state = authBloc.state;
    final user = authBloc.currentUser;

    if (state is Unauthenticated || (state is! AdminAuthenticated && user == null)) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    if (state is AdminAuthenticated || user?.isAdmin == true || user?.role == 'admin') {
      return MaterialPageRoute(builder: (_) => page);
    }

    // Authenticated fan without admin role -> Access Denied
    return MaterialPageRoute(builder: (_) => const AccessDeniedPage());
  }

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

      // Admin Console (Protected by Route Guard)
      case '/admin-dashboard':
      case '/admin/dashboard':
        return guardAdminRoute(const AdminDashboardPage());

      case '/admin/content':
        return guardAdminRoute(const AdminContentPage());

      case '/admin/content-edit':
        final article = settings.arguments as Map<String, dynamic>?;
        return guardAdminRoute(AdminContentEditPage(existingArticle: article));

      case '/admin/events':
        return guardAdminRoute(const AdminEventsPage());

      case '/admin/event-edit':
        final event = settings.arguments as Map<String, dynamic>?;
        return guardAdminRoute(AdminEventEditPage(existingEvent: event));

      case '/admin/products':
        return guardAdminRoute(const AdminProductsPage());

      case '/admin/product-edit':
        final product = settings.arguments as Map<String, dynamic>?;
        return guardAdminRoute(AdminProductEditPage(existingProduct: product));

      case '/admin/users-categories':
        return guardAdminRoute(const AdminUsersCategoriesPage());

      default:
        return null;
    }
  }
}
