class PublishChecklist {
  List<ChecklistItem> items;

  PublishChecklist() : items = [
    ChecklistItem('پیکیج نام یونیک ہے', false),
    ChecklistItem('ایپ آئیکن موجود ہے', false),
    ChecklistItem('پرائیویسی پالیسی تیار ہے', false),
    ChecklistItem('اسکرین شاٹس موجود ہیں', false),
    ChecklistItem('ایپ ڈسکرپشن تیار ہے', false),
    ChecklistItem('کیٹیگری منتخب ہے', false),
    ChecklistItem('APK سائن کیا ہوا ہے', false),
    ChecklistItem('پلے اسٹور اکاؤنٹ بن چکا ہے', false),
    ChecklistItem('ٹیسٹنگ مکمل ہو چکی ہے', false),
  ];

  bool get isReady => items.every((item) => item.completed);
  
  int get completedCount => items.where((item) => item.completed).length;
  
  int get totalCount => items.length;
  
  double get progress => completedCount / totalCount;

  void toggleItem(int index) {
    if (index >= 0 && index < items.length) {
      items[index].completed = !items[index].completed;
    }
  }

  void markAllIncomplete() {
    for (var item in items) {
      item.completed = false;
    }
  }

  List<ChecklistItem> get incompleteItems {
    return items.where((item) => !item.completed).toList();
  }

  List<ChecklistItem> get completedItems {
    return items.where((item) => item.completed).toList();
  }
}

class ChecklistItem {
  final String title;
  bool completed;

  ChecklistItem(this.title, this.completed);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      json['title'],
      json['completed'] ?? false,
    );
  }
}
