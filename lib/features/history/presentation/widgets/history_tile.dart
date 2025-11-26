import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/skin_engine/skin_protocol.dart';
import '../../../decision/data/decision_model.dart';

class HistoryTile extends StatelessWidget {
  final DecisionModel record;
  final VoidCallback onDelete;

  const HistoryTile({
    super.key,
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 解析皮肤模式，如果存的是旧数据或未知的，默认回退到 vintage
    final skinMode = SkinMode.values.firstWhere(
      (e) => e.name == record.skinModeName,
      orElse: () => SkinMode.vintage,
    );

    final isYes = record.result == "YES";
    final dateFormat = DateFormat('HH:mm');

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFFF3B30), // iOS Red
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // --- 左侧图标 (根据皮肤变化) ---
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _getThemeColor(skinMode).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getThemeIcon(skinMode),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          // --- 中间信息 ---
          title: Text(
            record.result, // YES / NO
            style: GoogleFonts.syne(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isYes ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            ),
          ),
          subtitle: Text(
            dateFormat.format(record.timestamp),
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
          ),
          // --- 右侧装饰 ---
          trailing: Icon(
            Icons.arrow_forward_ios, 
            size: 12, 
            color: Colors.grey[300]
          ),
        ),
      ),
    );
  }

  // 辅助方法：根据皮肤获取图标 Emoji
  String _getThemeIcon(SkinMode mode) {
    switch (mode) {
      case SkinMode.vintage: return "🪙";
      case SkinMode.healing: return "🍡";
      case SkinMode.cyber:   return "⚡️";
      case SkinMode.wish:    return "✨";
    }
  }

  // 辅助方法：根据皮肤获取主题色
  Color _getThemeColor(SkinMode mode) {
    switch (mode) {
      case SkinMode.vintage: return const Color(0xFFC6A664);
      case SkinMode.healing: return const Color(0xFFB5C99A);
      case SkinMode.cyber:   return const Color(0xFFBC13FE);
      case SkinMode.wish:    return const Color(0xFF2B5876);
    }
  }
}