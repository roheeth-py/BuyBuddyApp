import 'package:grocery_app/model/category_model.dart';

class GroceryItem {
  const GroceryItem(
    this.id,
    this.name,
    this.quantity,
    this.category,
  );

  final String id;
  final String name;
  final int quantity;
  final Category category;
}
