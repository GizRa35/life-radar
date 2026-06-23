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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("LIFE RADAR")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(kTurquoise)
                Spacer()
                Text(entry.weather)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(entry.score)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Risk Puanı")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(entry.label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(kTurquoise)
                }
            }
            Text("🌍 " + entry.quake)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.9))
                .lineLimit(1)
            Text("⚠️ " + entry.alert)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
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
