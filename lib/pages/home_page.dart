import 'package:flutter/material.dart';

import '../models/countdown_event.dart';
import '../services/storage_service.dart';
import '../widgets/countdown_card.dart';
import 'edit_page.dart';

/// 首页：展示所有倒数日事件
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  List<CountdownEvent> _events = [];
  bool _isLoading = true;

  // 交织动画控制器
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 加载事件并按规则排序：置顶在前，然后按剩余天数升序（未来近的在前，过去近的在前）
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _storage.getEvents();

    // 计算每个事件的天数差用于排序
    events.sort((a, b) {
      // 置顶优先
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      // 同一天数差则按创建时间倒序
      return 0;
    });
    // 再按天数差的绝对值排序（距离今天越近越靠前），但保持置顶分组
    events.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      final aDays = _daysAbs(a.targetDate);
      final bDays = _daysAbs(b.targetDate);
      if (aDays != bDays) return aDays.compareTo(bDays);
      return b.createdAt.compareTo(a.createdAt);
    });

    setState(() {
      _events = events;
      _isLoading = false;
    });

    // 启动交织动画
    _controller.forward(from: 0);
  }

  int _daysAbs(String dateStr) {
    final parts = dateStr.split('-');
    final target = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return target.difference(today).inDays.abs();
  }

  /// 跳转到编辑页（新建或编辑），返回时刷新列表
  Future<void> _openEditPage([CountdownEvent? event]) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditPage(event: event),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 自定义路由过渡：缩放 + 淡入
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      ),
    );
    // 返回后刷新
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 橙红渐变背景
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFF8F0)],
            stops: [0.0, 0.3],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: const Text(
                  '倒数日',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 28),
                  onPressed: () => _openEditPage(),
                ),
              ],
            ),
            // 列表
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_events.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = _events[index];
                  return _buildAnimatedCard(event, index);
                }, childCount: _events.length),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建带动画的卡片：交织（Staggered）淡入 + 上滑
  Widget _buildAnimatedCard(CountdownEvent event, int index) {
    // 每张卡片错开 80ms，动画持续 400ms
    final double start = (index * 0.08).clamp(0.0, 0.8);
    final double end = (start + 0.5).clamp(0.0, 1.0);

    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 40),
            child: child,
          ),
        );
      },
      child: CountdownCard(event: event, onTap: () => _openEditPage(event)),
    );
  }

  /// 空状态提示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: const Color(0xFFFF7043).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有倒数日',
            style: TextStyle(fontSize: 18, color: Color(0xFF8D6E63)),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角 + 添加你的第一个倒数日',
            style: TextStyle(fontSize: 14, color: Color(0xFFA1887F)),
          ),
        ],
      ),
    );
  }
}
