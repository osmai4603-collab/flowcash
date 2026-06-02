import 'package:equatable/equatable.dart';

abstract class StocktakingEvent extends Equatable {
  const StocktakingEvent();

  @override
  List<Object?> get props => [];
}

class LoadStocktakingEvent extends StocktakingEvent {
  const LoadStocktakingEvent();
}

class UpdateActualCountEvent extends StocktakingEvent {
  final int categoryId;
  final double count;
  const UpdateActualCountEvent(this.categoryId, this.count);

  @override
  List<Object?> get props => [categoryId, count];
}
