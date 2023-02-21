//
//  ViewExtensions.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/20.
//

import SwiftUI

extension View {

    public func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }

}
