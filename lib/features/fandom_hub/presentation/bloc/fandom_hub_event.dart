abstract class FandomHubEvent {
  const FandomHubEvent();
}

class LoadFandomHubContentEvent extends FandomHubEvent {
  final List<String>? selectedFandoms;
  const LoadFandomHubContentEvent({this.selectedFandoms});
}

class FilterContentByCategoryEvent extends FandomHubEvent {
  final String category;
  const FilterContentByCategoryEvent(this.category);
}

class SearchFandomContentEvent extends FandomHubEvent {
  final String query;
  const SearchFandomContentEvent(this.query);
}

class ToggleBookmarkPostEvent extends FandomHubEvent {
  final String postId;
  const ToggleBookmarkPostEvent(this.postId);
}

class ToggleBookmarkGlossaryEvent extends FandomHubEvent {
  final String termId;
  const ToggleBookmarkGlossaryEvent(this.termId);
}

class LoadAdvancedLoreEvent extends FandomHubEvent {
  final String? categoryFilter;
  const LoadAdvancedLoreEvent({this.categoryFilter});
}

class LoadBehindScenesEvent extends FandomHubEvent {
  final String? categoryFilter;
  const LoadBehindScenesEvent({this.categoryFilter});
}

class LoadInterviewsEvent extends FandomHubEvent {
  final String? categoryFilter;
  const LoadInterviewsEvent({this.categoryFilter});
}
