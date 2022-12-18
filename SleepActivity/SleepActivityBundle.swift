//
//  SleepActivityBundle.swift
//  SleepActivity
//
//  Created by Noam Efergan on 18/12/2022.
//

import WidgetKit
import SwiftUI

@main
struct SleepActivityBundle: WidgetBundle {
    var body: some Widget {
        SleepActivity()
        SleepActivityLiveActivity()
    }
}
