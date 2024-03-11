import 'package:erp/db/ErpDatabase.dart';
import 'package:erp/db/UserDao.dart';
import 'package:flutter/material.dart';

class DBProvider extends ChangeNotifier {
  late final ErpDatabase _database;
  late final UserDao _userDao;

  ErpDatabase get database => _database;

  UserDao get dao => _userDao;

  DBProvider(this._database, this._userDao);
}
