/// 倒数日事件数据模型
class CountdownEvent {
  /// 唯一标识
  final String id;

  /// 标题
  final String title;

  /// 目标日期，格式 yyyy-MM-dd
  final String targetDate;

  /// 备注（可选）
  final String note;

  /// 颜色标识（Color 的 value）
  final int color;

  /// 是否置顶
  final bool isPinned;

  /// 创建时间
  final DateTime createdAt;

  CountdownEvent({
    required this.id,
    required this.title,
    required this.targetDate,
    this.note = '',
    required this.color,
    this.isPinned = false,
    required this.createdAt,
  });

  /// 从 Map 转换为对象
  factory CountdownEvent.fromJson(Map<String, dynamic> json) {
    return CountdownEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      targetDate: json['targetDate'] as String,
      note: (json['note'] as String?) ?? '',
      color: json['color'] as int,
      isPinned: (json['isPinned'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转换为 Map 用于存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate,
      'note': note,
      'color': color,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 拷贝对象并修改部分字段
  CountdownEvent copyWith({
    String? title,
    String? targetDate,
    String? note,
    int? color,
    bool? isPinned,
  }) {
    return CountdownEvent(
      id: id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
    );
  }
}
