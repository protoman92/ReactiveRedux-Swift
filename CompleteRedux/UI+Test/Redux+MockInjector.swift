//
//  Redux+MockInjector.swift
//  CompleteRedux
//
//  Created by Hai Pham on 12/11/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Prop injector subclass that can be used for testing. For example:
///
///     class ViewController: ReduxCompatibleView {
///       var staticProps: StaticProps?
///       ...
///     }
///
///     func test() {
///       ...
///       let injector = MockInjector(...)
///       vc.staticProps = StaticProps(injector)
///       ...
///     }
///
/// This class keeps track of the injection count for each Redux-compatible
/// view.
public final class MockInjector<State>: PropInjector<State> {
  private let lock = NSRecursiveLock()
  private var _injectCount: [String : Int] = [:]
  
  /// Initialize with a mock store that does not have any functionality.
  convenience public init(forState: State.Type, runner: MainThreadRunnerType) {
    let store: DelegateStore<State> = .init(
      {fatalError()},
      {_ in fatalError()},
      {_,_ in fatalError()},
      {_ in fatalError()}
    )
    
    self.init(store: store, runner: runner)
  }
  
  /// Access the internal inject count statistics.
  public var injectCount: [String : Int] {
    return self._injectCount
  }
  
  /// Add one count for a compatible view injectee.
  ///
  /// - Parameters:
  ///   - cv: A Redux-compatible view.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  public override func injectProps<CV, MP>(_ cv: CV, _ op: CV.OutProps, _ mapper: MP.Type)
    -> ReduxSubscription where
    MP: PropMapperType,
    MP.PropContainer == CV,
    CV.GlobalState == State
  {
    self.addInjecteeCount(cv)
    return ReduxSubscription.noop
  }
  
  /// Check if a Redux view has been injected as many times as specified.
  ///
  /// - Parameters:
  ///   - view: A Redux-compatible view.
  ///   - times: An Int value.
  /// - Returns: A Bool value.
  public func didInject<View>(_ view: View, times: Int) -> Bool where
    View: PropContainerType
  {
    return self.getInjecteeCount(view) == times
  }
  
  /// Check if a Redux view has been injected as many times as specified.
  ///
  /// - Parameters:
  ///   - view: A Redux-compatible view.
  ///   - times: An Int value.
  /// - Returns: A Bool value.
  public func didInject<View>(_ type: View.Type, times: Int) -> Bool where
    View: PropContainerType
  {
    return self.getInjecteeCount(type) == times
  }
  
  /// Reset all internal statistics.
  public func reset() {
    self.lock.lock()
    defer { self.lock.unlock() }
    self._injectCount = [:]
  }
  
  private func addInjecteeCount(_ id: String) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self._injectCount[id] = self.injectCount[id, default: 0] + 1
  }
  
  /// Only store the class name because generally we only need to check how
  /// many times views/view controllers of a certain class have received
  /// injection.
  private func addInjecteeCount<View>(_ view: View) where View: PropContainerType {
    self.addInjecteeCount(String(describing: View.self))
  }
  
  private func getInjecteeCount(_ id: String) -> Int {
    self.lock.lock()
    defer { self.lock.unlock() }
    return self.injectCount[id, default: 0]
  }
  
  private func getInjecteeCount<View>(_ type: View.Type) -> Int where
    View: PropContainerType
  {
    return self.getInjecteeCount(String(describing: type))
  }
  
  private func getInjecteeCount<View>(_ view: View) -> Int where
    View: PropContainerType
  {
    return self.getInjecteeCount(View.self)
  }
}
