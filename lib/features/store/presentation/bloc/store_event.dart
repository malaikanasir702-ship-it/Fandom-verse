import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductCatalogEvent extends StoreEvent {
  final String? category;
  final String? sortBy;
  final String? searchQuery;

  const LoadProductCatalogEvent({
    this.category,
    this.sortBy,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, sortBy, searchQuery];
}

class FilterProductsByCategoryEvent extends StoreEvent {
  final String category;

  const FilterProductsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SortProductsByPriceEvent extends StoreEvent {
  final String sortBy; // 'price_low_high', 'price_high_low', 'rating'

  const SortProductsByPriceEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SearchProductsEvent extends StoreEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
