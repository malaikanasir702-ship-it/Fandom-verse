abstract class FandomHubEvent {
  const FandomHubEvent();
}

class LoadFandomHubContentEvent extends FandomHubEvent {
  const LoadFandomHubContentEvent();
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
