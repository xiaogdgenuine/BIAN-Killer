//
//  RectangleButton.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/20.
//

import SwiftUI

struct RectangleButton: View {
    let text: String
    var highlightByDefault = false
    let onTap: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .onHover {
            hovered = $0
        }
        .contentShape(Rectangle())
        .cursor(.pointingHand)
        .onTapGesture {
            onTap()
        }
        .border(Color.primary)
        .background(hovered ? Color.accentColor : highlightByDefault ? Color.accentColor.opacity(0.3) : Color(NSColor.textBackgroundColor))
    }
}
