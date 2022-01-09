//
//  SimpleWidget.swift
//  Portfolio
//
//  Created by MacBook Pro on 08/01/2022.
//

import WidgetKit
import SwiftUI

/// Determines how data is presented
struct PortfolioWidgetEntryView: View {

    // Entry is placeholder data type
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

/// Determines how widget is configured
struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next...")
        .description("Your #1 top-priority item.")
        // restricts size of the widget to small one
        .supportedFamilies([.systemSmall])
    }
}
