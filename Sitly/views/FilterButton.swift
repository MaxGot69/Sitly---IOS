//
//  FilterButton.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 08.07.2025.
//

import SwiftUI

struct FilterButton: View {
    let title : String
    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.08))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

