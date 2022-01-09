//
//  DataProvider.swift
//  Portfolio
//
//  Created by MacBook Pro on 08/01/2022.
//

import WidgetKit
import SwiftUI

/// Determines how data for widget is fetched
struct Provider: TimelineProvider {
    // added because swift cannot infer type of entry when the original file was split
    typealias Entry = SimpleEntry

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
        let itemRequest = dataController.fetchRequestForTopItems(count: 5)
        return dataController.result(for: itemRequest)
    }
}

/// Determines how data for widget is stored
struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}
