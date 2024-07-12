//
//  SFContentBlockerManager.swift
//  ScriptAway
//
//  Created by Kyle Nazario on 2/28/21.
//

#if !os(watchOS)
import Combine
import SafariServices

@available(macCatalyst 13.4, *)
public extension SFContentBlockerManager {
    static func reloadContentBlocker(withIdentifier identifier: String) -> AnyPublisher<Void, Error> {
        let reloadTracker = PassthroughSubject<Void, Error>()
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier) { error in
            if let error = error {
                reloadTracker.send(completion: .failure(error))
            } else {
                reloadTracker.send(())
            }
        }
        return reloadTracker.eraseToAnyPublisher()
    }

    static func getStateOfContentBlocker(withIdentifier identifier: String)
        -> AnyPublisher<SFContentBlockerState?, Error>
    {
        let stateTracker = PassthroughSubject<SFContentBlockerState?, Error>()
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: identifier) { state, error in
            if let error = error {
                stateTracker.send(completion: .failure(error))
            } else {
                stateTracker.send(state)
            }
        }
        return stateTracker.eraseToAnyPublisher()
    }
}
#endif
