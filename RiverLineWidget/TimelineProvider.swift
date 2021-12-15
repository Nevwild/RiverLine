//
//  TimelineProvider.swift
//  RiverLineWidgetExtension
//
//  Created by Nevill Wilder on 7/29/21.
//

import WidgetKit
import SwiftUI
import ComposableArchitecture

//struct Entry:TimelineEntry {
//    var date: Date
//    var entry: (Date) -> TimelineEntry
//}
//extension Entry {
//    static let Waves = Self(date: Date(), entry: { date in
//        WavesEntry(date: date, waves: [])
//    })
//}

//struct TimelineClient{
//    var snapshot: (TimelineProviderContext) -> Effect<WavesEntry, Error>
//    var timeline: (TimelineProviderContext) -> Effect<Timeline<WavesEntry>, Error>
//    var placeholder: (TimelineProviderContext) -> Effect<WavesEntry, Error>
//
//    struct Error: Swift.Error, Equatable {}
//}
//
//extension TimelineClient{
//    static let mock:TimelineClient = { Self(
//        snapshot: {context in Effect(value: WavesEntry(date: Date(), waves: []))},
//        timeline: {context in Effect(value: Timeline(entries: [WavesEntry(date: Date(), waves: [])], policy: .atEnd))},
//        placeholder: {context in Effect(value: WavesEntry(date: Date(), waves: []))}
//    )
//    }()
//}

//
//struct TCAProvider {
//    var snapshot: (in context: TimelineProviderContext, completion: @escaping (SimpleEntry) -> Void)
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {}
//
//    func placeholder(in context: Context) -> TimelineEntry {}
//
//}
//
