import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/repositories/i_store_repository.dart';
import '../../../../core/repositories/store_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final IStoreRepository _repository;
  String _currentCategory = 'All';
  String _currentSort = 'featured';
  String _currentQuery = '';

  StoreBloc({IStoreRepository? repository})
      : _repository = repository ?? StoreRepositoryImpl(),
        super(const StoreInitial()) {
    on<LoadProductCatalogEvent>(_onLoadProductCatalog);
    on<FilterProductsByCategoryEvent>(_onFilterByCategory);
    on<SortProductsByPriceEvent>(_onSortByPrice);
    on<SearchProductsEvent>(
      _onSearchProducts,
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
  }

  Future<void> _onLoadProductCatalog(
    LoadProductCatalogEvent event,
    Emitter<StoreState> emit,
  ) async {
    emit(const StoreLoading());
    try {
      if (event.category != null) _currentCategory = event.category!;
      if (event.sortBy != null) _currentSort = event.sortBy!;
      if (event.searchQuery != null) _currentQuery = event.searchQuery!;

      final rawData = await _repository.getMerchandise(
        category: _currentCategory == 'All' ? null : _currentCategory,
        sortBy: _currentSort,
        searchQuery: _currentQuery,
      );

      final products = rawData.map((e) => ProductEntity.fromMap(e)).toList();
      final featured = products.where((p) => p.isFeatured).toList();

      emit(StoreLoaded(
        products: products,
        featuredProducts: featured.isNotEmpty ? featured : products.take(3).toList(),
        selectedCategory: _currentCategory,
        selectedSort: _currentSort,
        searchQuery: _currentQuery,
      ));
    } catch (e) {
      emit(StoreError('Failed to load merchandise: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByCategory(
    FilterProductsByCategoryEvent event,
    Emitter<StoreState> emit,
  ) async {
    _currentCategory = event.category;
    add(LoadProductCatalogEvent(category: _currentCategory));
  }

  Future<void> _onSortByPrice(
    SortProductsByPriceEvent event,
    Emitter<StoreState> emit,
  ) async {
    _currentSort = event.sortBy;
    add(LoadProductCatalogEvent(sortBy: _currentSort));
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<StoreState> emit,
  ) async {
    _currentQuery = event.query;
    add(LoadProductCatalogEvent(searchQuery: _currentQuery));
  }
}
