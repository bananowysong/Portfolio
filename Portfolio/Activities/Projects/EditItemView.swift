//
//  EditingView.swift
//  Portfolio
//
//  Created by MacBook Pro on 14/11/2021.
//

import SwiftUI

struct EditItemView: View {
    let item: Item
    @EnvironmentObject var dataController: DataController
    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool

    var body: some View {
        Form {
            Section(content: {
                TextField("Item name", text: $title.onChange(update))
                TextField("Description", text: $detail.onChange(update))
            }, header: {
                Text("Basic settings")
            })

            Section(content: {
                Picker("Priority", selection: $priority.onChange(update)) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
            }, header: {
                Text("Priority")
            })
                .pickerStyle(SegmentedPickerStyle())

            Section {
                Toggle("Mark Completed", isOn: $completed.onChange(update))
            }
            .navigationTitle("Edit Item")
            .onDisappear(perform: save)
        }
    }

    init(item: Item) {
        self.item = item

        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    func update() {
        print("update")
        item.project?.objectWillChange.send()
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }

    /// saves changes to the item
    func save() {
        dataController.update(item)
    }
}

struct EditingView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {

        EditItemView(item: Item.example)
            .environmentObject(dataController)
    }
}
