//
//  Language.swift
//  AttendEase
//
//  Created by kazu on 2024/02/17.
//

import Foundation
class Language {
    private var bundle: Bundle?

    /**
     Setting language
     :param: code language code
     */
    func setLanguage(_ code: String) {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = nil
            return
        }
        self.bundle = bundle
    }

    /**
     Get word in Localizable.strings.
     :param: key Localizable.strings key
     */
    func localizedString(forKey key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}
