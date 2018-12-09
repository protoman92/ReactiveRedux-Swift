//
//  Redux+Saga+Put.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift

extension Redux.Saga {
  
  /// Effect whose output puts some external value into the redux store's
  /// managed state. We may also want to specify the dispatch queue on which
  /// to dispatch the action so that specific order (e.g. serial) may be
  /// achieved.
  final class PutEffect<State, P>: Effect<State, Any> {
    private let _actionCreator: (P) -> ReduxActionType
    private let _param: Redux.Saga.Effect<State, P>
    private let _dispatchQueue: DispatchQueue
    
    init(_ param: Redux.Saga.Effect<State, P>,
         _ actionCreator: @escaping (P) -> ReduxActionType,
         _ dispatchQueue: DispatchQueue) {
      self._actionCreator = actionCreator
      self._param = param
      self._dispatchQueue = dispatchQueue
    }
    
    override func invoke(_ input: Input<State>) -> Output<Any> {
      return _param.invoke(input)
        .map(self._actionCreator)
        .observeOn(ConcurrentDispatchQueueScheduler(queue: self._dispatchQueue))
        .map(input.dispatch)
    }
  }
}

extension ReduxSagaEffectType {
  
  /// Invoke a put effect on the current effect.
  ///
  /// - Parameters:
  ///   - actionCreator: The action creator function.
  ///   - dispatchQueue: The dispatch queue on which to put.
  /// - Returns: An Effect instance.
  public func put(
    _ actionCreator: @escaping (R) -> ReduxActionType,
    dispatchQueue: DispatchQueue = .main)
    -> Redux.Saga.Effect<State, Any>
  {
    return self.asEffect().asInput(for: {
      .put($0, actionCreator: actionCreator, dispatchQueue: dispatchQueue)})
  }
}
