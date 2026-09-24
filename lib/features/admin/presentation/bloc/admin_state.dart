import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminStatsLoaded extends AdminState {
  final Map<String, int> metrics;
  final List<Map<String, dynamic>> recentLogs;
  final List<Map<String, dynamic>> articles;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> categories;
  final String? successMessage;

  const AdminStatsLoaded({
    required this.metrics,
    required this.recentLogs,
    required this.articles,
    required this.events,
    required this.products,
    required this.users,
    required this.categories,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
        metrics,
        recentLogs,
        articles,
        events,
        products,
        users,
        categories,
        successMessage,
      ];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
