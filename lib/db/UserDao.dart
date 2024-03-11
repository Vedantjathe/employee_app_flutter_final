



import 'package:floor/floor.dart';

import '../models/User.dart';

@dao
abstract class UserDao {

  @Query('SELECT * FROM User')
  Future<List<User>> findAllPersons();

  @insert
  Future<void> insertPerson(User person);

  @Query('DELETE FROM user')
  Future<void> DeleteAllUser();

}