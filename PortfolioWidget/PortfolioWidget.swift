//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by MacBook Pro on 02/01/2022.
//

import WidgetKit
import SwiftUI

/// Determines how data for widget is fetched
struct Provider: TimelineProvider {

    /// This method returns whatever will be used in Provider..Entry. It is called by iOS when
    /// it wants to give the user a rough idea of what your widget might look like.
    ///　Unlike the other methods in this struct, this one needs to return its data immediately.
    /// It has to look about right.
    /// - Parameter context: Context
    /// - Returns: Provider.Entry
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }

    /// Called when iOS needs to know the current status of the widget (what should be shown right now)
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    /// Called when iOS needs to know all the future status of the widget, what should be shown in the future
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
       let entry = SimpleEntry(date: Date(), items: loadItems())

        // .never meaning that iOS should just let the last value in the array stay forever.
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    /// Creates data controler instance and then fetch request and then executes it
    /// - Returns: Array of Items
    func loadItems() -> [Item] {
        let dataController = DataController()
        let itemRequest = dataController.fetchRequestForTopItems(count: 1)
        return dataController.result(for: itemRequest)
    }
}

/// Determines how data for widget is stored
struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

/// Determines how data is presented
struct PortfolioWidgetEntryView: View {

    // .Entry is placeholder data type
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)

            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

@main
/// Determines how widget is configured
struct PortfolioWidget: Widget {
    let kind: String = "PortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
