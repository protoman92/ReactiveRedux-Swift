//
//  Redux.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/22/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import SafeNest
import SwiftFP

extension UIViewController {
  typealias PropInjector = Redux.UI.PropInjector<SafeNest>
}

extension UIView {
  typealias PropInjector = Redux.UI.PropInjector<SafeNest>
}

final class AppRedux {
  typealias State = SafeNest
  
  final class Path {
    static let rootPath = "main"
    static let numberPath = "\(Path.rootPath).number"
    static let stringPath = "\(Path.rootPath).string"
    static let sliderPath = "\(Path.rootPath).slider"
    static let textIndexesPath = "\(Path.rootPath).textIndexes"
    static let textPath = "\(Path.rootPath).texts"
    
    static func textItemPath(_ textIndex: Int) -> String {
      return "\(textPath).\(textIndex)"
    }
  }
  
  enum Action: ReduxActionType {
    case triggerClear
    case addNumber
    case minusNumber
    case string(String?)
    case slider(Double)
    case addTextItem
    case text(Int, String?)
    case deleteTextItem(Int)
  }
  
  final class Getter {
    static func number(state: State) -> Try<Int> {
      return state.value(at: Path.numberPath).cast(Int.self)
    }
  }
  
  final class Reducer {
    static func main(_ state: State, _ action: ReduxActionType) -> State {
      do {
        switch action {
        case let action as Action:
          switch action {
          case .triggerClear:
            return try state.updating(at: Path.rootPath, value: nil)
            
          case .addNumber:
            return try state.mapping(at: Path.numberPath, withMapper: {
              return $0.cast(Int.self).getOrElse(0) + 1
            })
            
          case .minusNumber:
            return try state.mapping(at: Path.numberPath, withMapper: {
              return $0.cast(Int.self).getOrElse(0) - 1
            })
            
          case .string(let string):
            return try state.updating(at: Path.stringPath, value: string)
            
          case .slider(let value):
            return try state.updating(at: Path.sliderPath, value: value)
            
          case .addTextItem:
            let mapper: State.TypedMapper<[Int], [Int]> = {
              $0.getOrElse([]) + ($0?.last).map({[$0 + 1]}).getOrElse([0])
            }
            
            return try state.mapping(at: Path.textIndexesPath, withMapper: mapper)
            
          case .text(let index, let value):
            return try state.updating(at: Path.textItemPath(index), value: value)
            
          case .deleteTextItem(let index):
            let mapper: State.TypedMapper<[Int], [Int]> = {
              var copy = $0
              copy?.remove(at: index)
              return copy
            }
            
            return try state.mapping(at: Path.textIndexesPath, withMapper: mapper)
          }
          
        default: return state
        }
      } catch (let e) {
        fatalError(e.localizedDescription)
      }
    }
  }
}
