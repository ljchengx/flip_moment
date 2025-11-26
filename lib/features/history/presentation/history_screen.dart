import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../decision/providers/decision_log_provider.dart';
import 'widgets/history_tile.dart';
import 'widgets/empty_history_view.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    // 监听数据库变化
    final historyList = ref.watch(decisionLogProvider);
    
    // 简单处理：如果为空显示 EmptyState
    if (historyList.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyHistoryView(
          title: loc.historyEmpty,
          description: loc.historyEmptyDesc,
        ),
      );
    }

    // 预处理数据：按日期分组
    // Map<String, List<DecisionModel>>
    final groupedMap = <String, List<dynamic>>{};
    for (var record in historyList) {
      final dateKey = _getDateKey(record.timestamp, loc);
      if (!groupedMap.containsKey(dateKey)) {
        groupedMap[dateKey] = [];
      }
      groupedMap[dateKey]!.add(record);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          loc.historyTitle, 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: groupedMap.keys.length,
        itemBuilder: (context, index) {
          final key = groupedMap.keys.elementAt(index);
          final records = groupedMap[key]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 日期 Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 0, 8),
                child: Text(
                  key.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              // --- 记录列表 ---
              ...records.map((record) {
                return HistoryTile(
                  record: record,
                  onDelete: () {
                    ref.read(decisionLogProvider.notifier).deleteRecord(record.id);
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  String _getDateKey(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return loc.today;
    if (target == today.subtract(const Duration(days: 1))) return loc.yesterday;
    return DateFormat('MMM dd, yyyy').format(date);
  }
}