package com.liferadar.life_radar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Ana ekran widget'ı — kişisel risk puanını gösterir.
class RiskWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.risk_widget).apply {
                val score = widgetData.getInt("risk_score", 0)
                val label = widgetData.getString("risk_label", "—") ?: "—"
                setTextViewText(R.id.widget_score, score.toString())
                setTextViewText(R.id.widget_label, label)

                // Widget'a dokununca uygulamayı aç.
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
