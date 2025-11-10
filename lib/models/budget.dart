import 'package:hive/hive.dart';
import 'category.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final CategoryType category;
  @HiveField(2)
  final double limit; // monthly limit
  @HiveField(3)
  final int year; // budget period year
  @HiveField(4)
  final int month; // 1..12

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.year,
    required this.month,
  });
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 3;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Budget(
      id: fields[0] as String,
      category: fields[1] as CategoryType,
      limit: (fields[2] as num).toDouble(),
      year: fields[3] as int,
      month: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.limit)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.month);
  }
}
