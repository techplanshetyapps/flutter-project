/// نموذج بيانات المهمة لتمثيل المهام المنزلية
class Task {
  // المعرف الفريد الخاص بالمهمة
  final String id;
  
  // عنوان أو اسم المهمة
  final String title;
  
  // فئة أو تصنيف المهمة (مثلاً: يومي أو أسبوعي)
  final String category; 
  
  // مؤشر حالة اكتمال المهمة (هل تمت أم لا)
  bool isCompleted;
  
  // الوقت المخصص لتنفيذ المهمة
  final String time;

  // المُنشئ الأساسي لإنشاء كائن مهمة جديد مع تعيين القيم المطلوبة والاختيارية
  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    required this.time,
  });

  // مُنشئ مصنع لإنشاء كائن مهمة من بيانات بتنسيق خريطة قادمة من الخادم أو واجهة برمجة التطبيقات
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'يومي',
      isCompleted: json['completed'] ?? false,
      time: json['time'] ?? '08:00 ص',
    );
  }

  // دالة لتحويل كائن المهمة إلى تنسيق خريطة لتسهيل إرساله أو تخزينه
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'completed': isCompleted,
      'time': time,
    };
  }
}