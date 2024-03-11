import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/User.dart';
import 'UserDao.dart';

part 'ErpDatabase.g.dart';

@Database(version: 1, entities: [User])
abstract class ErpDatabase extends FloorDatabase {
  UserDao get personDao;
}
