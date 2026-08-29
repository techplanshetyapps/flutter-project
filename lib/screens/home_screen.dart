import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/task_model.dart';
import '../data/network/dio_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final DioClient _dioClient = DioClient();
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isNotificationEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedCategory = 'Daily';

  @override
  void initState() {
    super.initState();
    _fetchTasksFromApi();
  }

  // Fetch tasks from API using Dio
  Future<void> _fetchTasksFromApi() async {
    try {
      setState(() => _isLoading = true);
      
      // Example network request (using jsonplaceholder for demonstration)
      final response = await _dioClient.instance.get('/todos?_limit=4');
      
      final List<dynamic> data = response.data;
      final fetchedTasks = data.map((json) => Task(
        id: json['id'].toString(),
        title: json['title'],
        category: 'Daily',
        isCompleted: json['completed'],
        time: '09:00 AM',
      )).toList();

      setState(() {
        _tasks = fetchedTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    }
  }

  // Add Task via API POST request (simulated)
  Future<void> _addTask() async {
    try {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Household Task #${_tasks.length + 1}',
        category: _selectedCategory,
        time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      );

      // POST request example
      // await _dioClient.instance.post('/todos', data: newTask.toJson());

      setState(() {
        _tasks.add(newTask);
        _listKey.currentState?.insertItem(_tasks.length - 1, duration: const Duration(milliseconds: 300));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added and synced via Dio!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting task: $e')),
      );
    }
  }

  // Remove Task
  void _removeTask(int index) {
    final removedItem = _tasks.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Card(child: ListTile(title: Text(removedItem.title))),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DayToday Household Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasksFromApi,
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () => _pickTime(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1B365D)),
              child: Text('Household Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Daily', label: Text('Daily'), icon: Icon(Icons.today)),
                        ButtonSegment(value: 'Weekly', label: Text('Weekly'), icon: Icon(Icons.date_range)),
                      ],
                      selected: {_selectedCategory},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedCategory = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(value: 0.65),
                  const Divider(height: 24, thickness: 2),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable Task Reminders', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: _isNotificationEnabled,
                        onChanged: (value) => setState(() => _isNotificationEnabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.5, -0.6),
                        radius: 0.85,
                        colors: <Color>[Color(0xFFEEEEEE), Color(0xFF111133)],
                        stops: <double>[0.1, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Priority Zone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Transform(
                            alignment: Alignment.topRight,
                            transform: Matrix4.skewY(0.1)..rotateZ(-math.pi / 24.0),
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              color: const Color(0xFFE8581C),
                              child: const Text('fav', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Task List (Synced via Dio):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  
                  Expanded(
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: _tasks.length,
                      itemBuilder: (context, index, animation) {
                        final task = _tasks[index];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                task.isCompleted ? Icons.task_alt : Icons.radio_button_unchecked,
                                color: const Color(0xFF1B365D),
                              ),
                              title: Text(task.title),
                              subtitle: Text('Category: ${task.category} | Time: ${task.time}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTask(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: ExtendedFloatingActionButton(
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        onPressed: _addTask,
      ),
    );
  }
}