import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/countdown_event.dart';

/// 事件存储服务，基于 shared_preferences
class StorageService {
  static const String _key = 'countdown_events';
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  /// 获取所有事件
  Future<List<CountdownEvent>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
    return jsonList
        .map((json) => CountdownEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 保存所有事件（覆盖）
  Future<void> saveEvents(List<CountdownEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  /// 新增一个事件
  Future<void> addEvent(CountdownEvent event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  /// 更新一个事件
  Future<void> updateEvent(CountdownEvent event) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  /// 删除一个事件
  Future<void> deleteEvent(String id) async {
    final events = await getEvents();
    events.removeWhere((e) => e.id == id);
    await saveEvents(events);
  }
}
