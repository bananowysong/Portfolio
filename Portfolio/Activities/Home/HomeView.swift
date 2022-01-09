//
//  HomeView.swift
//  Portfolio
//
//  Created by MacBook Pro on 12/11/2021.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct HomeView: View {
    static let tag: String? = "Home"
    @StateObject var viewModel: ViewModel

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: $viewModel.upNext)
                        ItemListView(title: "More to explore", items: $viewModel.moreToExplore)
                    }
                    .padding(.horizontal)

                }
                if let item = viewModel.selectedItem {

                    // performs navigation programatically when app is launched
                    // using spotlight
                    NavigationLink(destination: EditItemView(item: item),
                                   tag: item,
                                   selection: $viewModel.selectedItem,
                                   label: EmptyView.init
                    ).id(item)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Add Data", action: viewModel.addSampleData)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Remove User", action: viewModel.removeUser)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem(_:))
        }
    }

    /// Looks into NSUserActivity for a specific Core spotlight key to read identifier of item
    /// - Parameter userActivity: NSUserActivity
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
