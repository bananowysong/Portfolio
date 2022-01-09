//
//  ComplexPortfolioWidget.swift
//  PortfolioWidgetExtension
//
//  Created by MacBook Pro on 08/01/2022.
//

import WidgetKit
import SwiftUI

/// Determines how data is presented
struct PortfolioWIdgetMultipleEntryView: View {
    var entry: Provider.Entry

    // allows us to dynamically control what we want to show (contains widget sizes)
    @Environment(\.widgetFamily) var widgetFamily

    @Environment(\.sizeCategory) var sizeCategory

    /// Returns different number of items depending on current font. Default is equivalent to medium size.
    var items: ArraySlice<Item> {
        let itemCount: Int

        switch widgetFamily {
        case .systemSmall:
                itemCount = 1
        case .systemLarge:
            if sizeCategory < .extraLarge {
                itemCount = 5
            } else {
                itemCount = 4
            }
        default:
            if sizeCategory < .extraLarge {
                itemCount = 3
            } else {
                itemCount = 2
            }
        }

        return entry.items.prefix(itemCount)
    }

    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.project?.color ?? "Light Blue")
                        .frame(width: 5)
                        .clipShape(Capsule())

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)
                            .layoutPriority(1)

                        if let projectTitle = item.project?.projectTitle {
                            Text(projectTitle)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(20)
    }
}

/// Determines how complex widget is configured
struct ComplexPortfolioWidget: Widget {
    let kind: String = "ComplexPortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWIdgetMultipleEntryView(entry: entry)
        }
        .configurationDisplayName("Up next...")
        .description("Your most important items.")
    }
}
