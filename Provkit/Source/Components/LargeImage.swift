//
//  LargeImage.swift
//  Provkit
//
//  Created by Jakub on 2024-09-02.
//

import SwiftUI

struct LargeImage: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 150, weight: .light))
            .foregroundStyle(.gray)
    }
}

#Preview {
    LargeImage(systemName: "wifi")
}
