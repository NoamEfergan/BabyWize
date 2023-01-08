//
//  FeedActivityBundle.swift
//  FeedActivity
//
//  Created by Noam Efergan on 06/01/2023.
//

import WidgetKit
import SwiftUI

@main
struct FeedActivityBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            FeedActivityLiveActivity()
        }
    }
}
