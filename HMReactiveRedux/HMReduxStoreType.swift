//
//  HMReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxSwift

/// Classes that implement this protocol should act as a redux-compliant store.
public protocol HMReduxStoreType: HMStateFactoryType {
    
    /// Trigger an action.
    func actionTrigger() -> AnyObserver<Action?>
    
    /// Subscribe to this stream to receive action notifications.
    func actionStream() -> Observable<Action>
    
    /// Trigger a state.
    func stateTrigger() -> AnyObserver<State>

    /// Subscribe to this stream to receive state notifications.
    func stateStream() -> Observable<State>
}

public extension HMReduxStoreType {
    
    /// Dispatch an action.
    ///
    /// - Parameter action: An Action instance.
    public func dispatch(_ action: Action) {
        actionTrigger().onNext(action)
    }
}