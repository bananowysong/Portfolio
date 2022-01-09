//
//  SharedProject.swift
//  Portfolio
//
//  Created by MacBook Pro on 08/01/2022.
//

import Foundation

struct SharedProject: Identifiable {
    let id: String
    let title: String
    let detail: String
    let owner: String
    let closed: Bool

    static let example = SharedProject(id: "1", title: "Example", detail: "Detail", owner: "TwoStraws", closed: false)
}
