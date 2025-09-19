import 'package:coffee_tracker/features/coffee_tracker/domain/entities/kv_type.dart';

class CoffeeOptions {
  final List<KvType> coffeeTypes;
  final List<KvType> sizes;

  CoffeeOptions({required this.coffeeTypes, required this.sizes});
}
