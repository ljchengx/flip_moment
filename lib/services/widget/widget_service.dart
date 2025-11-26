import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  // Android 组件的 Provider 类名 (必须与 Android 代码一致)
  static const String _androidWidgetName = 'FlipMomentWidgetProvider';

  // iOS 的 App Group ID (Android 不需要，但为了代码统一保留参数)
  static const String _appGroupId = 'group.com.es.flipmoment'; 

  /// 核心方法：更新桌面组件数据
  Future<void> updateWidgetData({
    required String lastResult, // "YES" 或 "NO"
    required int totalCount,    // 总次数
    required int streak,        // 连续天数
  }) async {
    try {
      // 1. 保存数据 (Key 必须与 Android Kotlin 代码中读取的 Key 完全一致)
      await HomeWidget.saveWidgetData<String>('last_result', lastResult);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);
      await HomeWidget.saveWidgetData<int>('streak', streak);
      
      // 2. 广播更新通知 (唤醒原生代码刷新 UI)
      await HomeWidget.updateWidget(
        iOSName: 'FlipMomentWidget', 
        androidName: _androidWidgetName,
      );
      
      print("✅ Widget Data Synced: $lastResult");
    } catch (e) {
      print("⚠️ Widget Sync Error: $e");
    }
  }
}

final widgetServiceProvider = Provider<WidgetService>((ref) => WidgetService());