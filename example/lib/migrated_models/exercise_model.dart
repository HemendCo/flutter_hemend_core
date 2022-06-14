import 'dart:convert';

import 'package:hemend/debug/error_handler.dart';
import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

const _idMap = {
  'اسکات': 1,
  'شنا روی دیوار': 2,
  'بالا آوردن پای چپ از پهلو': 3,
  'بالا آوردن پای راست از پهلو': 4,
  'پل': 5,
  'دست زدن بالای سر': 6,
  'پلانک': 7,
  'کرانچ دوچرخه در حالت ایستاده': 8,
  'کرانچ با برخورد دست ها پشت پا': 9,
  'فایر هایدرنت چپ': 10,
  'فایر هایدرنت راست': 11,
  'هیل تاچ': 12,
  'ضربه پای چپ به عقب و بالا': 13,
  'ضربه پای راست به عقب و بالا': 14,
  'بال بال زدن ضربه ای پاها': 15,
  'کرانچ دوچرخه': 16,
  'کشش عضلات نزدیک کننده پاها': 17,
  'شناگر و سوپرمن': 18,
  'کرانچ دوچرخه ایستاده': 19,
  'لانچ': 20,
  'اسکات پا باز': 21,
  'پل سرشانه ': 22,
  'کرانچ معکوس': 23,
  'کرانچ شکم': 24,
  'حرکت پرنده-سگ': 25,
  'کشش کبری': 26,
  'کشش شانه': 27,
  'کیک از پشت': 28,
  'پروانه': 29,
  'کشش چهار سر ران پای چپ با کمک دیوار': 30,
  'کشش چهار سر ران پای راست با کمک دیوار': 31,
  'کشش پشت ساق پای چپ': 32,
  'کشش پشت ساق پای راست': 33,
  'کشش سه سر بازو-دست چپ': 34,
  'کشش سه سر بازو-دست راست': 35,
  'حرکت بچه': 36,
  'کشش گربه-گاو': 37,
  'کشش پروانه ای پاها': 38,
  'کشش چرخش خوابیده-چپ': 39,
  'کشش چرخش خوابیده-راست': 40,
  'خنده ی ماهی': 41,
  'پف کردن لب': 42,
  'کشیدن لب به پایین ': 43,
  'ماریلین ': 44,
  'لبخند ': 45,
  'آ ای او یو ': 46,
  ' بالا و پایین کردن سر': 47,
  'پهلو به پهلو': 48,
  'متمایل به پهلوها': 49,
  ' کشش گردن به سمت چپ': 50,
  'کشش گردن به سمت راست': 51,
  'کشش عضلات کتف چپ': 52,
  'کشش عضلات کتف راست': 53,
  'چرخش شانه به سمت عقربه های سمت': 54,
  'چرخش شانه به سمت خلاف عقربه های ساعت': 55,
  'شانه به بیرون': 56,
  'چرخش دست ها بالای سر (ساعتگرد)': 57,
  'چرخش دست های بالای سر (پادساعتگرد)': 58,
  'کشش عضلات سه سر چپ': 59,
  'کشش عضلات سه سر راست': 60,
  'قلاب دستان در پشت': 61,
  'خوابیده روی زمین': 62,
  'کشش کبرا': 63,
  'چرخش زانو سمت عقربه های ساعت': 64,
  'چرخش زانو خلاف عقربه های ساعت': 65,
  'بالا اوردن زانو تا قفسه سینه': 66,
  'کشش چهارگانه': 67,
  'جهش به اطراف': 68,
  'کشش دست': 69,
  'ضربه به باسن': 70,
  'قدم های بلند': 71,
  'کشش سمت چپ با دیوار': 72,
  'کشش سمت راست با دیوار': 73,
  'فشار به دیوار سمت چپ': 74,
  'فشار به دیوار به سمت راست': 75,
  'خم شدن به جلو': 76,
  'کشش زانو به چپ': 77,
  'کشش زانو به راست': 78,
  'کشش عضلات سرینی سمت چپ': 79,
  'کشش عضلات سرینی سمت راست': 80,
  'کشش همسترینگ نشسته سمت چپ': 81,
  'کشش همسترینگ نشسته سمت راست': 82,
  'کشش پروانه نشسته': 83
};

@HiveType(typeId: 201)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  final int quantity;
  @HiveField(1)
  final ExerciseExecutionType type;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final double kcal;
  @HiveField(4)
  final double duration;

  @HiveField(5)
  final String description;
  @HiveField(6)
  final String gifName;
  String get gifAddr {
    if (!gifName.contains('null')) {
      return gifName;
    }
    if (name == 'فایر هیدرانت چپ') return 'gif10.gif';
    return 'gif11.gif';
  }

  // String get gifName {
  //   return 'gif${_idMap[name]}.gif';
  // }
  ExerciseModel({
    required this.quantity,
    required this.type,
    required this.name,
    required this.kcal,
    required this.duration,
    required this.description,
    required this.gifName,
  });

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'type': type.toMap(),
      'name': name,
      'kcal': kcal,
      'duration': duration,
      'description': description,
      'gifName': gifName,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      quantity: map['quantity']?.toInt() ?? 0,
      type: ExerciseExecutionType.fromMap(map['type']),
      name: map['name'] ?? '',
      kcal: map['kcal']?.toDouble() ?? 0.0,
      duration: map['duration']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      gifName: map['gifName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseModel.fromJson(String source) => ExerciseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseModel(quantity: $quantity, type: $type, name: $name, kcal: $kcal, duration: $duration, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseModel &&
        other.quantity == quantity &&
        other.type == type &&
        other.name == name &&
        other.kcal == kcal &&
        other.duration == duration &&
        other.description == description;
  }

  @override
  int get hashCode {
    return quantity.hashCode ^ type.hashCode ^ name.hashCode ^ kcal.hashCode ^ duration.hashCode ^ description.hashCode;
  }
}

@HiveType(typeId: 210)
enum ExerciseExecutionType {
  @HiveField(0)
  unit,
  @HiveField(1)
  time;

  Map<String, dynamic> toMap() {
    switch (this) {
      case ExerciseExecutionType.unit:
        return {
          'type': 'unit',
        };
      case ExerciseExecutionType.time:
        return {
          'type': 'time',
        };
    }
  }

  static ExerciseExecutionType fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'unit':
        return ExerciseExecutionType.unit;
      case 'time':
        return ExerciseExecutionType.time;
    }
    throw ErrorHandler('cannot convert $map to ExerciseExecutionType');
  }
}
