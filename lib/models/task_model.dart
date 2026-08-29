class Task {
  final String id;
  final String title;
  final String category; // 'Daily' or 'Weekly'
  bool isCompleted;
  final String time;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    required this.time,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Daily',
      isCompleted: json['completed'] ?? false,
      time: json['time'] ?? '08:00 AM',
    );
  }

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