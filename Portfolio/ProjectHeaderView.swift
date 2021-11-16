//
//  ProjectHeaderView.swift
//  Portfolio
//
//  Created by MacBook Pro on 14/11/2021.
//

import SwiftUI

struct ProjectHeaderView: View {
    @ObservedObject var project: Project

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(project.projectTitle)

                if #available(iOS 15.0, *) {
                    ProgressView(value: project.completionAmount)
                        .tint(Color(project.projectColor))
                } else {
                    ProgressView(value: project.completionAmount)
                        .accentColor(Color(project.projectColor))
                }
            }

            Spacer()

            NavigationLink(destination: EditProjectView(project: project)) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
        }
        .padding(.bottom, 10)
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectHeaderView(project: Project.example)
    }
}
