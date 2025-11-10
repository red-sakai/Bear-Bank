import 'package:hive/hive.dart';
import 'category.dart';

@HiveType(typeId: 2)
class BankTransaction extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final bool isExpense; // true expense, false income
  @HiveField(4)
  final CategoryType category;
  @HiveField(5)
  final String note;

  BankTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.category,
    this.note = '',
  });
}

class BankTransactionAdapter extends TypeAdapter<BankTransaction> {
  @override
  final int typeId = 2;

  @override
  BankTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BankTransaction(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      amount: (fields[2] as num).toDouble(),
      isExpense: fields[3] as bool,
      category: fields[4] as CategoryType,
      note: (fields[5] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, BankTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.isExpense)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.note);
  }
}
