import WidgetKit
import SwiftUI

private let kAppGroup = "group.com.liferadar.lifeRadar"
private let kTurquoise = Color(red: 0.0, green: 0.72, blue: 0.85)
private let kNavy = Color(red: 0.04, green: 0.14, blue: 0.26)

struct RiskEntry: TimelineEntry {
    let date: Date
    let score: Int
    let label: String
    let weather: String
    let quake: String
    let alert: String
}

struct Provider: TimelineProvider {
    private func read() -> RiskEntry {
        let d = UserDefaults(suiteName: kAppGroup)
        return RiskEntry(
            date: Date(),
            score: d?.integer(forKey: "risk_score") ?? 0,
            label: d?.string(forKey: "risk_label") ?? "—",
            weather: d?.string(forKey: "weather") ?? "—",
            quake: d?.string(forKey: "quake") ?? "—",
            alert: d?.string(forKey: "alert") ?? "—"
        )
    }

    func placeholder(in context: Context) -> RiskEntry {
        RiskEntry(date: Date(), score: 0, label: "—", weather: "—",
                  quake: "Yakın deprem yok", alert: "Kritik uyarı yok")
    }

    func getSnapshot(in context: Context, completion: @escaping (RiskEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RiskEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [read()], policy: .after(next)))
    }
}

struct RiskWidgetEntryView: View {
    var entry: RiskEntry

    private var levelColor: Color {
        if entry.score >= 67 { return Color(red: 0.91, green: 0.30, blue: 0.24) } // kırmızı
        if entry.score >= 34 { return Color(red: 0.96, green: 0.65, blue: 0.14) } // turuncu
        return Color(red: 0.18, green: 0.80, blue: 0.44) // yeşil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            // Üst: marka + hava
            HStack {
                Text("LIFE RADAR")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.0)
                    .foregroundColor(kTurquoise)
                Spacer()
                Text(entry.weather)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
            }

            // Risk puanı + seviye (renkli)
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("\(entry.score)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(levelColor)
                VStack(alignment: .leading, spacing: 1) {
                    Text("RİSK PUANI")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.5))
                    Text(entry.label)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(levelColor)
                }
                Spacer()
            }

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)

            // Son deprem + günün uyarısı
            HStack(alignment: .top, spacing: 5) {
                Text("🌍")
                    .font(.system(size: 11))
                Text(entry.quake)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(1)
            }
            HStack(alignment: .top, spacing: 5) {
                Text("⚠️")
                    .font(.system(size: 10))
                Text(entry.alert)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
    }
}

struct RiskWidget: Widget {
    let kind: String = "RiskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                RiskWidgetEntryView(entry: entry)
                    .containerBackground(kNavy, for: .widget)
            } else {
                RiskWidgetEntryView(entry: entry)
                    .background(kNavy)
            }
        }
        .configurationDisplayName("Life Radar")
        .description("Kişisel risk puanı, hava ve son gelişmeler.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct RiskWidgetBundle: WidgetBundle {
    var body: some Widget {
        RiskWidget()
    }
}
