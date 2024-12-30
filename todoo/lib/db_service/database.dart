import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  static Database? _database;

  // Truyền trả database đã khởi tạo
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initializeDatabase();
      return _database!;
    }
  }

  // Khởi tạo cơ sở dữ liệu SQLite
  Future<Database> initializeDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''CREATE TABLE PersonalTask (
            id TEXT PRIMARY KEY,
            work TEXT,
            done INTEGER
          )''',
        );
      },
    );
  }

  // Thêm task vào SQLite
  Future<void> addTaskSQLite(Map<String, dynamic> taskData, String collectionName) async {
    try {
      var db = await database;
      await db.insert(
        collectionName,
        taskData,
        conflictAlgorithm: ConflictAlgorithm.replace, 
      );
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  // Lấy task từ SQLite
  Future<List<Map<String, dynamic>>> getTasksFromSQLite(String collectionName) async {
    var db = await database;
    return await db.query(collectionName);
  }

  // Cập nhật trạng thái task (done)
  Future<void> toggleTaskStatus(String id, String collectionName) async {
    var db = await database;
    var task = await db.query(
      collectionName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (task.isNotEmpty) {
      bool isDone = task[0]['done'] == 1; //  (1 là hoàn thành, 0 là chưa hoàn thành)
      await db.update(
        collectionName,
        {'done': isDone ? 0 : 1}, 
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Xóa task
  Future<void> removeMethod(String id, String collectionName) async {
    var db = await database;
    await db.delete(
      collectionName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cập nhật công việc trong SQLite
  Future<void> updateTask(String id, String updatedTask, String collectionName) async {
    var db = await database;

    // Cập nhật công việc trong db
    await db.update(
      collectionName,
      {'work': updatedTask}, 
      where: 'id = ?', 
      whereArgs: [id], 
    );
  }


   // in table ra console
  Future<void> printTableContent(String tableName) async {
  try {
    var db = await database;
    var result = await db.query(tableName); 
    print("Dữ liệu trong bảng $tableName:");
    result.forEach((row) {
      print(row);
    });
  } catch (e) {
    print("Lỗi khi in dữ liệu: $e");
  }
}

}
