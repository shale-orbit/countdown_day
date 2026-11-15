import 'package:flutter/material.dart';
import '../models/countdown_event.dart';
import '../services/storage_service.dart';
import '../utils/date_util.dart';

/// 添加/编辑倒数日页面
class EditPage extends StatefulWidget {
  /// 传入事件为编辑模式，不传为新建模式
  final CountdownEvent? event;

  const EditPage({super.key, this.event});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final StorageService _storage = StorageService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  DateTime? _selectedDate;
  late int _selectedColor;
  bool _isPinned = false;

  // 橙红系可选颜色
  static const List<int> _colorOptions = [
    0xFFFF6B35, // 橙红
    0xFFF7931E, // 橙黄
    0xFFFF7043, // 深橙
    0xFFE53935, // 红
    0xFFFB8C00, // 橙
    0xFFFFA726, // 浅橙
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _noteController = TextEditingController(text: event?.note ?? '');
    _selectedDate =
        event != null ? DateUtil.parseDate(event.targetDate) : null;
    _selectedColor = event?.color ?? _colorOptions[0];
    _isPinned = event?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 打开日期选择器
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: DateTime(now.year + 50),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7043),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// 保存事件
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择目标日期')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final dateStr = DateUtil.formatDate(_selectedDate!);

    if (widget.event != null) {
      // 编辑模式
      final updated = widget.event!.copyWith(
        title: title,
        targetDate: dateStr,
        note: note,
        color: _selectedColor,
        isPinned: _isPinned,
      );
      await _storage.updateEvent(updated);
    } else {
      // 新建模式
      final newEvent = CountdownEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        targetDate: dateStr,
        note: note,
        color: _selectedColor,
        isPinned: _isPinned,
        createdAt: DateTime.now(),
      );
      await _storage.addEvent(newEvent);
    }

    if (mounted) Navigator.pop(context);
  }

  /// 删除事件
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: const Text('确定要删除这个倒数日吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '删除',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && widget.event != null) {
      await _storage.deleteEvent(widget.event!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.event != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(isEdit ? '编辑倒数日' : '新建倒数日'),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 标题
            _buildSectionLabel('标题'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('请输入标题'),
              style: const TextStyle(color: Color(0xFF3E2723)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '标题不能为空';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 目标日期
            _buildSectionLabel('目标日期'),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: _inputDecoration(
                    _selectedDate != null
                        ? DateUtil.formatDateChinese(_selectedDate!)
                        : '请选择日期',
                    suffixIcon: Icons.calendar_today,
                  ),
                  style: TextStyle(
                    color: _selectedDate != null
                        ? const Color(0xFF3E2723)
                        : const Color(0xFFA1887F),
                  ),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 备注
            _buildSectionLabel('备注（可选）'),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration('写点什么吧…'),
              style: const TextStyle(color: Color(0xFF3E2723)),
            ),
            const SizedBox(height: 24),

            // 颜色标识
            _buildSectionLabel('颜色标识'),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _colorOptions.map((colorValue) {
                final isSelected = colorValue == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorValue),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: const Color(0xFF3E2723), width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 置顶
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '置顶',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Switch(
                    value: _isPinned,
                    onChanged: (value) => setState(() => _isPinned = value),
                    activeThumbColor: const Color(0xFFFF7043),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 删除按钮（仅编辑模式）
            if (isEdit)
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除此事件'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935),
                  side: const BorderSide(color: Color(0xFFE53935)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 输入框装饰
  InputDecoration _inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA1887F)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: const Color(0xFFFF7043))
          : null,
    );
  }

  /// 分区标题
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5D4037),
        ),
      ),
    );
  }
}
