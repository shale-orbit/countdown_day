import 'package:flutter_test/flutter_test.dart';
import 'package:countdown_day/utils/date_util.dart';

void main() {
  group('DateUtil', () {
    test('parseDate 正确解析 yyyy-MM-dd', () {
      final date = DateUtil.parseDate('2026-12-01');
      expect(date.year, 2026);
      expect(date.month, 12);
      expect(date.day, 1);
    });

    test('formatDate 格式化为 yyyy-MM-dd', () {
      final date = DateTime(2026, 3, 5);
      expect(DateUtil.formatDate(date), '2026-03-05');
    });

    test('formatDateChinese 格式化为中文日期', () {
      final date = DateTime(2026, 3, 5);
      expect(DateUtil.formatDateChinese(date), '2026年03月05日');
    });

    test('daysFromToday 未来日期返回正数', () {
      final today = DateUtil.today();
      final future = today.add(const Duration(days: 10));
      expect(DateUtil.daysFromToday(future), 10);
    });

    test('daysFromToday 过去日期返回负数', () {
      final today = DateUtil.today();
      final past = today.subtract(const Duration(days: 5));
      expect(DateUtil.daysFromToday(past), -5);
    });

    test('daysFromToday 今天返回 0', () {
      final today = DateUtil.today();
      expect(DateUtil.daysFromToday(today), 0);
    });

    test('daysFromToday 忽略时分秒', () {
      // 目标日期是今天但时间是 23:59，应该返回 0
      final now = DateTime.now();
      final lateToday = DateTime(now.year, now.month, now.day, 23, 59);
      expect(DateUtil.daysFromToday(lateToday), 0);
    });
  });
}
