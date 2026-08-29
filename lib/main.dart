import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

void main() {
  runApp(const HouseholdAgendaApp());
}

class HouseholdAgendaApp extends StatelessWidget {
  const HouseholdAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda DayToday Task Systems',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B365D),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7BB0),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Simple Task Model
class Task {
  final String id;
  final String title;
  final String category;
  bool isCompleted;
  final String time;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    required this.time,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  // Dio client configuration
  late final Dio _dio;
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isNotificationEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedCategory = 'Daily';

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _fetchTasksFromApi();
  }

  // Fetch tasks with a secure fallback for Web / CORS environments
  Future<void> _fetchTasksFromApi() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/todos?_limit=4');
      final List<dynamic> data = response.data;
      
      setState(() {
        _tasks = data.map((json) => Task(
          id: json['id'].toString(),
          title: json['title'],
          category: 'Daily',
          isCompleted: json['completed'],
          time: '09:00 AM',
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Fallback local mock data so the app never shows a blank/infinite loading screen
      setState(() {
        _tasks = [
          Task(id: '1', title: 'Clean Kitchen (Fallback)', category: 'Daily', time: '08:00 AM'),
          Task(id: '2', title: 'Grocery Shopping (Fallback)', category: 'Weekly', time: '10:30 AM'),
        ];
        _isLoading = false;
      });
    }
  }

  void _addTask() {
    final int newIndex = _tasks.length;
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Household Task #${newIndex + 1}',
      category: _selectedCategory,
      time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
    );

    setState(() {
      _tasks.add(newTask);
      _listKey.currentState?.insertItem(newIndex, duration: const Duration(milliseconds: 300));
    });
  }

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

                  const Text('Task List:', style: TextStyle(fontWeight: FontWeight.bold)),
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
      // Corrected Floating Action Button constructor
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        onPressed: () {
          _addTask();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully!')),
          );
        },
      ),
    );
  }
}