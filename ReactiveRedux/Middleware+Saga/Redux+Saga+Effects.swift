//
//  Redux+Saga+Effects.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension Redux.Saga {
  public final class Effects {
    public typealias Effect = Redux.Saga.Effect
    typealias Call = Redux.Saga.CallEffect
    typealias Empty = Redux.Saga.EmptyEffect
    typealias Just = Redux.Saga.JustEffect
    typealias Put = Redux.Saga.PutEffect
    typealias Select = Redux.Saga.SelectEffect
    typealias TakeLatest = Redux.Saga.TakeLatestEffect
    
    /// Create an empty effect.
    ///
    /// - Returns: An Effect instance.
    public static func empty<State, R>() -> Effect<State, R> {
      return Empty()
    }
    
    /// Create a just effect.
    ///
    /// - Parameters:
    ///   - value: The value to form the effect with.
    ///   - type: Type of state to help the compiler.
    /// - Returns: An Effect instance.
    public static func just<State, R>(
      _ value: R, forState type: State.Type) -> Effect<State, R>
    {
      return Just(value)
    }
    
    /// Create a select effect.
    ///
    /// - Parameter selector: The state selector function.
    /// - Returns: An Effect instance.
    public static func select<State, R>(
      _ selector: @escaping (State) -> R) -> Effect<State, R>
    {
      return SelectEffect(selector)
    }
    
    /// Create a put effect.
    ///
    /// - Parameters:
    ///   - param: The parameter to put into redux state.
    ///   - actionCreator: The action creator function.
    /// - Returns: An Effect instance.
    public static func put<State, P>(
      _ param: Effect<State, P>,
      actionCreator: @escaping (P) -> ReduxActionType) -> Effect<State, Any>
    {
      return Put(param, actionCreator)
    }
    
    /// Create a call effect with an Observable.
    ///
    /// - Parameters:
    ///   - param: The parameter to call with.
    ///   - callCreator: The call creator function.
    /// - Returns: An Effect instance.
    public static func call<State, P, R>(
      param: Effect<State, P>,
      callCreator: @escaping (P) -> Observable<R>) -> Effect<State, R>
    {
      return Call(param, callCreator)
    }
    
    /// Create a call effect with a callback-style async function.
    ///
    /// - Parameters:
    ///   - param: The parameter to call with.
    ///   - callCreator: The call creator function.
    /// - Returns: An Effect instance.
    public static func call<State, P, R>(
      param: Effect<State, P>,
      callCreator: @escaping (P, (Try<R>) -> Void) -> Void) -> Effect<State, R>
    {
      return call(param: param) {(param) in
        return Observable.create({obs in
          callCreator(param, {
            do {
              obs.onNext(try $0.getOrThrow())
              obs.onCompleted()
            } catch let e {
              obs.onError(e)
            }
          })
          
          return Disposables.create()
        })
      }
    }
    
    /// Create a take latest effect.
    ///
    /// - Parameters:
    ///   - actionType: The type of action to filter.
    ///   - paramExtractor: The param extractor function.
    ///   - effectCreator: The effect creator function.
    /// - Returns: An Effect instance.
    public static func takeLatest<State, Action, P, R>(
      actionType: Action.Type,
      paramExtractor: @escaping (Action) -> P?,
      effectCreator: @escaping (P) -> Effect<State, R>)
      -> Effect<State, R> where Action: ReduxActionType
    {
      return TakeLatest(actionType, paramExtractor, effectCreator)
    }
  }
}