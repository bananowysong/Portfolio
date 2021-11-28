//
//  AwardsView.swift
//  Portfolio
//
//  Created by MacBook Pro on 20/11/2021.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(dataController.hasEearned(award: award) ? Color(award.color) : Color.secondary.opacity(0.5))
                        }
                        .accessibilityLabel(
                            Text(dataController.hasEearned(award: award) ? "Unlocked: \(award.name)" : "Locked")
                        )
                        .accessibilityHint(Text(award.description))
                    }
                }
            }
            .navigationTitle("Awards")
            .alert(isPresented: $showingAwardDetails) {
                if dataController.hasEearned(award: selectedAward) {
                    return Alert(title: Text("Unlocked: \(selectedAward.name)"), message: Text(selectedAward.description), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Locked"), message: Text(selectedAward.description), dismissButton: .default(Text("OK")))
                }
            }
            SelectSomethingView()
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        AwardsView()
            .environmentObject(dataController)
    }
}
