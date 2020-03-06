//
//  Category.swift
//  Todoey
//
//  Created by David Louis Lin on 09.02.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour = ""
    let items = List<Item>()
}
