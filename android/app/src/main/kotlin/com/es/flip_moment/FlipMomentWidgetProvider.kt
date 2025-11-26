package com.es.flip_moment

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class FlipMomentWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // 1. 读取 Flutter 传过来的数据 (Key 要对应)
                val lastResult = widgetData.getString("last_result", "--")
                val totalCount = widgetData.getInt("total_count", 0)
                val streak = widgetData.getInt("streak", 0)

                // 2. 更新 UI
                setTextViewText(R.id.tv_result, lastResult)
                setTextViewText(R.id.tv_stats, "Total: $totalCount | 🔥 $streak")
                
                // 3. (可选) 进阶动态样式：根据结果变色
                // if (lastResult == "YES") {
                //    setTextColor(R.id.tv_result, android.graphics.Color.parseColor("#34C759"))
                // }
            }

            // 4. 提交更新
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}