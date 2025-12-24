import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final String? categoryName;

  const Service({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.categoryName,
  });

  @override
  List<Object?> get props => [id, name, price];
}
