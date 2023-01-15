//
//  NavigationViewModel.swift
//
//
//  Created by Noam Efergan on 15/01/2023.
//

import SwiftUI
import Models

// MARK: - NavigationViewModel
public final class NavigationViewModel: ObservableObject {
    @Published public var path: [Screens] = []
}
