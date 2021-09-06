//
//  NSItemProvider.swift
//  NSItemProvider
//
//  Created by Kyle Nazario on 9/1/21.
//

import Combine
import Foundation

public extension NSItemProvider {
    @available(macOS 10.15, iOS 13.0, *)
    func loadItem(
        forTypeIdentifier identifier: String,
        options: [AnyHashable: Any]?
    ) -> PassthroughSubject<NSSecureCoding?, Error> {
        let subject = PassthroughSubject<NSSecureCoding?, Error>()
        loadItem(forTypeIdentifier: identifier, options: options) { content, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            subject.send(content)
            subject.send(completion: .finished)
        }
        return subject
    }
}
