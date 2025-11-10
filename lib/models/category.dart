import 'package:hive/hive.dart';

// Manual adapter (no codegen) to keep setup simple.
@HiveType(typeId: 1)
enum CategoryType {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  shopping,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  bills,
  @HiveField(5)
  health,
  @HiveField(6)
  savings,
  @HiveField(7)
  other,
}

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 1;

  @override
  CategoryType read(BinaryReader reader) {
    final index = reader.readByte();
    return CategoryType.values[index];
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    writer.writeByte(obj.index);
  }
}

extension CategoryMeta on CategoryType {
  String get label => switch (this) {
        CategoryType.food => 'Food',
        CategoryType.transport => 'Transport',
        CategoryType.shopping => 'Shopping',
        CategoryType.entertainment => 'Entertainment',
        CategoryType.bills => 'Bills',
        CategoryType.health => 'Health',
        CategoryType.savings => 'Savings',
        CategoryType.other => 'Other',
      };
}
