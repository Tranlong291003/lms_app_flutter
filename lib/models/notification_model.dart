class NotificationModel {
  final String notiId;
  final String uid;
  final String title;
  final String content;
  final String icon;
  final String color;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notiId,
    required this.uid,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notiId: json['noti_id'].toString(),
      uid: json['uid'].toString(),
      title: json['title'].toString(),
      content: json['content'].toString(),
      icon:
          (json['icon'] == null || json['icon'].toString().isEmpty)
              ? 'person'
              : json['icon'].toString(),
      color: json['color'].toString(),
      isRead:
          json['is_read'] is bool
              ? json['is_read']
              : json['is_read'].toString() == 'true' || json['is_read'] == 1,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noti_id': notiId,
      'uid': uid,
      'title': title,
      'content': content,
      'icon': icon,
      'color': color,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? notiId,
    String? uid,
    String? title,
    String? content,
    String? icon,
    String? color,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notiId: notiId ?? this.notiId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
