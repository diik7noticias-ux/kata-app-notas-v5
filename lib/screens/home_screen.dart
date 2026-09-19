import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:org_kata_notasv5/models/task.dart';
import 'package:org_kata_notasv5/utils/db_helper.dart';

part 'home_screen.g.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  Future<void> _initializeDB() async {
    await Hive.initFlutter();
    await Hive.registerAdapter(TaskAdapter());
    taskBox = await Hive.openBox<Task>('tasks');
    setState(() {});
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _taskController.text,
        isCompleted: false,
      );
      taskBox.add(newTask);
      _taskController.clear();
      setState(() {});
    }
  }

  void _toggleTaskCompletion(String id) {
    final task = taskBox.values.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    taskBox.put(task.id, task);
    setState(() {});
  }

  void _deleteTask(String id) {
    final task = taskBox.values.firstWhere((t) => t.id == id);
    taskBox.delete(task.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V5'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: taskBox.length,
        itemBuilder: (context, index) {
          final task = taskBox.values.elementAt(index);
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleTaskCompletion(task.id),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(task.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(hintText: 'Digite a tarefa'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addTask();
                      Navigator.pop(context);
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}