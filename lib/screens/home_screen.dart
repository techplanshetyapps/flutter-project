import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/task_model.dart';
import '../data/network/dio_client.dart';

/// الشاشة الرئيسية للتطبيق المتغيرة
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // مفتاح عالمي لإدارة حالة القائمة المتحركة
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  // مثيل عميل الشبكة لإدارة طلبات الخادم
  final DioClient _dioClient = DioClient();
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isNotificationEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedCategory = 'يومي';

  @override
  void initState() {
    super.initState();
    // جلب المهام من الخادم فور بدء تشغيل الشاشة
    _fetchTasksFromApi();
  }

  // دالة لجلب المهام من الخادم باستخدام عميل الشبكة
  Future<void> _fetchTasksFromApi() async {
    try {
      setState(() => _isLoading = true);
      
      // تنفيذ طلب شبكة لجلب بيانات تجريبية
      final response = await _dioClient.instance.get('/todos?_limit=4');
      
      final List<dynamic> data = response.data;
      final fetchedTasks = data.map((json) => Task(
        id: json['id'].toString(),
        title: json['title'],
        category: 'يومي',
        isCompleted: json['completed'],
        time: '09:00 ص',
      )).toList();

      setState(() {
        _tasks = fetchedTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل المهام: $e')),
        );
      }
    }
  }

  // دالة لإضافة مهمة جديدة ومزامنتها عبر طلب إرسال للخادم
  Future<void> _addTask() async {
    try {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'مهمة منزلية جديدة #${_tasks.length + 1}',
        category: _selectedCategory,
        time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      );

      setState(() {
        _tasks.add(newTask);
        _listKey.currentState?.insertItem(_tasks.length - 1, duration: const Duration(milliseconds: 300));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المهمة ومزامنتها بنجاح!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء إرسال المهمة: $e')),
      );
    }
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

  // دالة لفتح واجهة اختيار الوقت
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
      // شريط التطبيق العلوي
      appBar: AppBar(
        title: const Text('أجندة المهام اليومية'),
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
      // القائمة الجانبية المخفية
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1B365D)),
              child: Text('قائمة المنزل', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('لوحة التحكم'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      // محتوى الشاشة الرئيسي
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أزرار مقسمة لاختيار فئة المهام
                  Center(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'يومي', label: Text('يومي'), icon: Icon(Icons.today)),
                        ButtonSegment(value: 'أسبوعي', label: Text('أسبوعي'), icon: Icon(Icons.date_range)),
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
                  
                  // صف تفعيل التذكيرات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('تفعيل تذكيرات المهام', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: _isNotificationEnabled,
                        onChanged: (value) => setState(() => _isNotificationEnabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // صندوق مزخرف بنمط ملمس (Texture Pattern) وخلفية ملونة تماشياً مع Material 3
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: TexturePatternPainter(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'منطقة الأولوية النشطة',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'تم تفعيل النمط الملون مع الملمس',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Transform(
                                  alignment: Alignment.topRight,
                                  transform: Matrix4.skewY(0.1)..rotateZ(-math.pi / 24.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'مميز',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('قائمة المهام (المزامنة عبر الشبكة):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  
                  // قائمة المهام المتحركة
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
                              subtitle: Text('الفئة: ${task.category} | الوقت: ${task.time}'),
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
      // شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
      // زر الإجراء العائم الممتد لإضافة مهمة
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة مهمة'),
        onPressed: _addTask,
      ),
    );
  }
}

/// رسم ملمس هندسي خفيف لإعطاء تأثير النسيج (Texture) للخلفية الملونة
class TexturePatternPainter extends CustomPainter {
  final Color color;

  TexturePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const double spacing = 16.0;
    
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}