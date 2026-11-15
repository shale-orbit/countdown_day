import 'package:flutter/material.dart';
import '../models/countdown_event.dart';
import '../utils/date_util.dart';

/// 倒数日事件卡片
class CountdownCard extends StatelessWidget {
  final CountdownEvent event;
  final VoidCallback onTap;

  const CountdownCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final targetDate = DateUtil.parseDate(event.targetDate);
    final days = DateUtil.daysFromToday(targetDate);

    // 判断是未来、过去还是今天
    final bool isFuture = days > 0;
    final bool isToday = days == 0;
    final int absDays = days.abs();

    final String label = isToday
        ? '就是今天'
        : isFuture
            ? '还有'
            : '已过';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: Color(event.color), width: 6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题 + 置顶标识
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (event.isPinned)
                        const Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Color(0xFFFF7043),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateUtil.formatDateChinese(targetDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 天数区域
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 数字使用 AnimatedSwitcher，变化时有淡入淡出+上滑动画
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          '$absDays',
                          key: ValueKey<int>(absDays),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? const Color(0xFFE53935)
                                : Color(event.color),
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          '天',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 备注
                  if (event.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.note,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFA1887F),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
