//
//  KNPickerSettings.swift
//  KNContactsPicker
//
//  Created by Dragos-Robert Neagu on 29/10/2019.
//  Copyright © 2019 Dragos-Robert Neagu. All rights reserved.
//

import Foundation
import UIKit

public enum KNContactsPickerMode {
    case single
    case multiple
}

public enum KNContactSubtitleValue {
    case none
    case phoneNumber
    case emailAddress
    case company
}

public struct KNPickerSettings {
    
    public var pickerTitle: String = "Contacts"
    public var searchBarPlaceholder: String = "Search contacts"

    public var selectionMode: KNContactsPickerMode = .single
    public var subtitleDisplay: KNContactSubtitleValue = .none
    
    public init() {}
    
}
