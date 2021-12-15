////
////  RiverLineWidget.swift
////  RiverLineWidget
////
////  Created by Nevill Wilder on 7/29/21.
////
//
//import WidgetKit
//import SwiftUI
//import ComposableArchitecture
//
//struct WidgetStore {
//    let entries: WavesEntry
//}
//
//struct WidgetEnvironment {
//    let waveProvider:WaveProvider
//}
//
//
//struct WavesEntry: TimelineEntry {
//    var date: Date
//    let waves: 
//}
//
//struct RiverLineWidgetEntryView : View {
//    let store: Store<RiverState, RiverAction>
//
//    var body: some View {
//        WithViewStore(self.store) { viewStore in
//            NavigationView{
//                List{
//                    ForEach(viewStore.waves){ wave in
//                        WaveView(wave: wave)
//                            .listRowBackground(wave.surfable()
//                                               ? Color.green
//                                               : Color.red
//                            )
//                    }
//                }
//            }
//
//        }
//    }
//}
//
//@main
//struct RiverLineWidget: Widget {
//    let kind: String = "RiverLineWidget"
//
//    var body: some WidgetConfiguration {
//
//        StaticConfiguration(kind: kind, provider: WaveProvider()) { entry in
//            
//        }
//        .configurationDisplayName("Surfable Waves Widget")
//        .description("See which waves are surfable today in Spokane")
//    }
//}
//
//struct RiverLineWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        RiverLineWidgetEntryView(entry: WavesEntry(date: Date(), waves: []))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
//
////struct WaveProvider: TimelineProvider {
////    let store: Store<RiverState, RiverAction>
////    func placeholder(in context: Context) -> WavesEntry {
////        WavesEntry(date: Date(), waves: [])
////    }
////
////    func getSnapshot(in context: Context, completion: @escaping (TimelineEntry) -> ()) {
////        let entry = WavesEntry(date: Date(), waves: store)
////        completion(entry)
////    }
////
////    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
////        var entries: [SimpleEntry] = []
////
////        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
////        let currentDate = Date()
////        for hourOffset in 0 ..< 5 {
////            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
////            let entry = SimpleEntry(date: entryDate)
////            entries.append(entry)
////        }
////
////        let timeline = Timeline(entries: entries, policy: .atEnd)
////        completion(timeline)
////    }
////}
//
//
