import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';

abstract class GoodsCostEvent extends Equatable {
  const GoodsCostEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoodsCostEvent extends GoodsCostEvent {
  const LoadGoodsCostEvent();
}

class AddGoodsCostEvent extends GoodsCostEvent {
  final GoodsCostEntity cost;
  const AddGoodsCostEvent(this.cost);

  @override
  List<Object?> get props => [cost];
}

class DeleteGoodsCostEvent extends GoodsCostEvent {
  final int id;
  const DeleteGoodsCostEvent(this.id);

  @override
  List<Object?> get props => [id];
}
