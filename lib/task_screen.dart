import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  final String id;
  final String name;
  final Color color;

  Task({required this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TextEditingController _taskNameController = TextEditingController();
  Color _selectedColor = Colors.green; // Alterado para uma cor presente na lista de opções
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Nome da Tarefa',
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Color>(
              value: _selectedColor,
              onChanged: (value) {
                setState(() {
                  _selectedColor = value!;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text('Prioridade Baixa'),
                  value: Colors.green,
                ),
                DropdownMenuItem(
                  child: Text('Prioridade Média'),
                  value: Colors.yellow,
                ),
                DropdownMenuItem(
                  child: Text('Prioridade Alta'),
                  value: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addTask();
              },
              child: Text('Adicionar Tarefa'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(tasks[index].name),
                    tileColor: tasks[index].color,
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTask(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    setState(() {
      final newTask = Task(
        id: DateTime.now().toString(),
        name: _taskNameController.text,
        color: _selectedColor,
      );
      tasks.add(newTask);
      _saveTasks();
      _taskNameController.clear();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        tasks = taskList.map((taskString) {
          final Map<String, dynamic> taskMap = jsonDecode(taskString);
          return Task.fromMap(taskMap);
        }).toList();
      });
    }
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskList =
        tasks.map((task) => jsonEncode(task.toMap())).toList();
    prefs.setStringList('tasks', taskList);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskScreen(),
    );
  }
}
