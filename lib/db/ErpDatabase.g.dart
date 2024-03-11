// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ErpDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorErpDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ErpDatabaseBuilder databaseBuilder(String name) =>
      _$ErpDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ErpDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ErpDatabaseBuilder(null);
}

class _$ErpDatabaseBuilder {
  _$ErpDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$ErpDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$ErpDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<ErpDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ErpDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ErpDatabase extends ErpDatabase {
  _$ErpDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _personDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER NOT NULL, `username` TEXT NOT NULL, `usertype` TEXT NOT NULL, `assignedRole` TEXT NOT NULL, `userid` TEXT NOT NULL, `userDepartment` TEXT NOT NULL, `isUnBlockedForBilling` TEXT NOT NULL, `locationID` TEXT NOT NULL, `department` TEXT NOT NULL, `designation` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get personDao {
    return _personDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'usertype': item.usertype,
                  'assignedRole': item.assignedRole,
                  'userid': item.userid,
                  'userDepartment': item.userDepartment,
                  'isUnBlockedForBilling': item.isUnBlockedForBilling,
                  'locationID': item.locationID,
                  'department': item.department,
                  'designation': item.designation
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<List<User>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM User',
        mapper: (Map<String, Object?> row) => User(
            username: row['username'] as String,
            usertype: row['usertype'] as String,
            assignedRole: row['assignedRole'] as String,
            userid: row['userid'] as String,
            userDepartment: row['userDepartment'] as String,
            isUnBlockedForBilling: row['isUnBlockedForBilling'] as String,
            locationID: row['locationID'] as String,
            department: row['department'] as String,
            designation: row['designation'] as String));
  }

  @override
  Future<void> DeleteAllUser() async {
    await _queryAdapter.queryNoReturn('DELETE FROM user');
  }

  @override
  Future<void> insertPerson(User person) async {
    await _userInsertionAdapter.insert(person, OnConflictStrategy.abort);
  }
}
