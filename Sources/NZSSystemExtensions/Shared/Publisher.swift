//
//  Publisher.swift
//  JavaSnipt
//
//  Created by Kyle Nazario on 4/7/21.
//

import Combine

public extension Publisher {
    func void() -> Publishers.Map<Self, Void> {
        map { _ in () }
    }
}
