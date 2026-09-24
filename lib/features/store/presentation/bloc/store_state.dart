import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreLoading extends StoreState {
  const StoreLoading();
}

class StoreLoaded extends StoreState {
  final List<ProductEntity> products;
  final List<ProductEntity> featuredProducts;
  final String selectedCategory;
  final String selectedSort;
  final String searchQuery;

  const StoreLoaded({
    required this.products,
    required this.featuredProducts,
    this.selectedCategory = 'All',
    this.selectedSort = 'featured',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
        products,
        featuredProducts,
        selectedCategory,
        selectedSort,
        searchQuery,
      ];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}
