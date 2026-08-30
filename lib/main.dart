import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

// نقطة بداية تشغيل التطبيق
void main() {
  runApp(const HouseholdAgendaApp());
}

// التطبيق الجذري الرئيسي
class HouseholdAgendaApp extends StatelessWidget {
  const HouseholdAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام أجندة المهام المنزلية',
      debugShowCheckedModeBanner: false,
      
      // إعدادات الترجمة واللغات الداعمة
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // اللغة العربية (الافتراضية)
        Locale('en', ''), // اللغة الإنجليزية
      ],
      locale: const Locale('ar', ''),
      
      themeMode: ThemeMode.system,
      
      // سمة الوضع الفاتح (Light Theme)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B365D),
          brightness: Brightness.light,
        ),
      ),
      
      // سمة الوضع الداكن (Dark Theme)
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

// نموذج بيانات المهمة (Task Model)
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

// الشاشة الرئيسية للتطبيق (تتفاعل وتتغير حالتها)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // مفتاح عالمي لإدارة حالة القائمة المتحركة 
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  // تعريف عميل شبكة Dio
  late final Dio _dio;
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isNotificationEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedCategory = 'يومي';

  @override
  void initState() {
    super.initState();
    // إعدادات اتصال Dio الأساسية
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    // جلب المهام تلقائياً عند فتح الشاشة
    _fetchTasksFromApi();
  }

  // دالة لجلب المهام من الخادم عبر API مع وضع بيانات احتياطية في حال الفشل
  Future<void> _fetchTasksFromApi() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/todos?_limit=4');
      final List<dynamic> data = response.data;
      
      setState(() {
        _tasks = data.map((json) => Task(
          id: json['id'].toString(),
          title: json['title'],
          category: 'يومي',
          isCompleted: json['completed'],
          time: '09:00 ص',
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      // بيانات تجريبية احتياطية محلية لكي لا تظهر شاشة تحميل فارغة أبداً
      setState(() {
        _tasks = [
          Task(id: '1', title: 'تنظيف المطبخ (احتياطي)', category: 'يومي', time: '08:00 ص'),
          Task(id: '2', title: 'تسوق البقالة (احتياطي)', category: 'أسبوعي', time: '10:30 ص'),
        ];
        _isLoading = false;
      });
    }
  }

  // دالة لإضافة مهمة جديدة للقائمة مع تأثير حركي
  void _addTask() {
    final int newIndex = _tasks.length;
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'مهمة منزلية جديدة #${newIndex + 1}',
      category: _selectedCategory,
      time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
    );

    setState(() {
      _tasks.add(newTask);
      _listKey.currentState?.insertItem(newIndex, duration: const Duration(milliseconds: 300));
    });
  }

  // دالة لحذف مهمة من القائمة مع تأثير الحركة
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

  // دالة لفتح منتقي الوقت 
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      // شريط التطبيق العلوي مع الترجمة الديناميكية
      appBar: AppBar(
        title: Text(localizations.dailyAgendaTitle),
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
      
      // القائمة الجانبية للتنقل
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1B365D)),
              child: Text(localizations.homeList, style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(localizations.controlPanel),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      
      // جسم الشاشة الرئيسي
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'يومي', label: Text(localizations.daily), icon: const Icon(Icons.today)),
                        ButtonSegment(value: 'أسبوعي', label: Text(localizations.weekly), icon: const Icon(Icons.date_range)),
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
                      Text(localizations.enableTaskReminders, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                          Text(localizations.priorityArea, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Transform(
                            alignment: Alignment.topRight,
                            transform: Matrix4.skewY(0.1)..rotateZ(-math.pi / 24.0),
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              color: const Color(0xFFE8581C),
                              child: Text(localizations.featured, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(localizations.tasksList, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              subtitle: Text('${localizations.section}: ${task.category} | ${localizations.time}: ${task.time}'),
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
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.list), label: localizations.tasks),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: localizations.settings),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(localizations.addTask),
        onPressed: () {
          _addTask();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.taskAddedSuccessfully)),
          );
        },
      ),
    );
  }
}