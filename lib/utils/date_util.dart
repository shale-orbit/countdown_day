/// 日期相关工具方法
class DateUtil {
  /// 将 yyyy-MM-dd 格式的字符串解析为 DateTime（本地时间，时分秒归零）
  static DateTime parseDate(String dateStr) {
    final parts = dateStr.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  /// 获取今天的日期（时分秒归零，用于和目标日期对比）
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 计算目标日期距今天的天数差
  /// 返回值为正数表示未来（还有 N 天），负数表示过去（已过 N 天），0 表示今天
  static int daysFromToday(DateTime target) {
    final targetMidnight = DateTime(target.year, target.month, target.day);
    return targetMidnight.difference(today()).inDays;
  }

  /// 把单个数字补零成两位字符串
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 格式化日期为 yyyy-MM-dd
  static String formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  /// 格式化日期为 yyyy年MM月dd日，用于显示
  static String formatDateChinese(DateTime date) {
    return '${date.year}年${_twoDigits(date.month)}月${_twoDigits(date.day)}日';
  }
}
