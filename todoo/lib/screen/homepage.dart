import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:todoo/db_service/database.dart';  

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isGridView = false;
  TextEditingController todoController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];

  // Lấy dữ liệu từ SQLite
  getOnTheLoad() async {
    tasks = await DatabaseService().getTasksFromSQLite(
        _selectedIndex == 0 ? "PersonalTask" : "Done");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().initializeDatabase(); // taoj db
    getOnTheLoad();
    DatabaseService().printTableContent('PersonalTask');// in db
  }

  // Hiển thị menu chỉnh sửa và xóa
  void showEditRemoveMenu(Map<String, dynamic> task) {
    _selectedIndex == 0
        ? showModalBottomSheet(
            context: context,
            builder: (context) => Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    openEditBox(task);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Remove'),
                  onTap: () async {
                    await DatabaseService().removeMethod(task["id"], "PersonalTask");
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
              ],
            ),
          )
        : null;
  }

  // Hiển thị hộp thoại chỉnh sửa
  Future openEditBox(Map<String, dynamic> task) {
    todoController.text = task["work"];
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Task Name'),
              SizedBox(height: 10),
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  onPressed: () async {
                    String updatedTask = todoController.text;
                    await DatabaseService().updateTask(task["id"], updatedTask, "PersonalTask");
                    todoController.text = "";
                    Navigator.pop(context);
                    getOnTheLoad();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị công việc
  Widget getWork() {
  return tasks.isNotEmpty
      ? Expanded(
          child: _isGridView
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> task = tasks[index];
                    bool isDone = task["done"] == 1; 
                    return GestureDetector(
                      onLongPress: () => showEditRemoveMenu(task),
                      child: Card(
                        elevation: 4,
                        child: CheckboxListTile(
                          activeColor: Colors.green.shade400,
                          title: Text(
                            task["work"],
                            style: TextStyle(
                              fontSize: 16,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          value: isDone,
                          onChanged: (bool? newValue) async {
                            if (newValue != null) {  
                              await DatabaseService().toggleTaskStatus(task["id"], "PersonalTask");
                              setState(() {
                                task["done"] = newValue ? 1 : 0; 
                              });
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> task = tasks[index];
                    bool isDone = task["done"] == 1; 
                    return GestureDetector(
                      onLongPress: () => showEditRemoveMenu(task),
                      child: CheckboxListTile(
                        activeColor: Colors.green.shade400,
                        title: Text(
                          task["work"],
                          style: TextStyle(
                            fontSize: 16,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        value: isDone,
                        onChanged: (bool? newValue) async {
                          if (newValue != null) { 
                            await DatabaseService().toggleTaskStatus(task["id"], "PersonalTask");
                            setState(() {
                              task["done"] = newValue ? 1 : 0; 
                            });
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
        )
      : Center(child: CircularProgressIndicator());
}

  // Bottom Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    getOnTheLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                openBox();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            )
          : null,
      appBar: AppBar(
        title: Text("Task Manager"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedIndex == 0 ? 'To do Tasks' : 'Completed Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            getWork(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              child: Text(
                  _isGridView ? 'Switch to ListView' : 'Switch to GridView'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'To do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Done',
          ),
        ],
      ),
    );
  }

  // Thêm tác vụ mới
  Future openBox() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Task Name'),
              SizedBox(height: 10),
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  hintText: "Enter task",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  onPressed: () async {
                    String taskName = todoController.text.trim();
                    if (taskName.isNotEmpty) {
                      String id = randomAlphaNumeric(100); 
                      Map<String, dynamic> newTask = {
                        'work': taskName,
                        'id': id,
                        'done': 0,  
                      };

                      // Thêm công việc vào cơ sở dữ liệu SQLite
                      await DatabaseService().addTaskSQLite(newTask, "PersonalTask");
                      
                      // Cập nhật lại danh sách công việc
                      todoController.clear();
                      Navigator.pop(context);
                      getOnTheLoad();
                    } else {
                      // Thông báo nếu nhập liệu rỗng
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task name cannot be empty')),
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
