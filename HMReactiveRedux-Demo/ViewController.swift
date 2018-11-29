//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import SafeNest

final class ViewController: UIViewController {
  @IBOutlet private weak var counterTF: UITextField!
  @IBOutlet private weak var addBT: UIButton!
  @IBOutlet private weak var minusBT: UIButton!
  @IBOutlet private weak var stringTF1: UITextField!
  @IBOutlet private weak var stringTF2: UITextField!
  @IBOutlet private weak var slideTF: UITextField!
  @IBOutlet private weak var valueSL: UISlider!
  @IBOutlet private weak var clearButton: ConfirmButton!
  @IBOutlet weak var textTable: UITableView!
  
  public var staticProps: StaticProps? {
    didSet {
      _ = self.staticProps?.connector
        .connect(view: self.clearButton, mapper: self.clearButton)
    }
  }
  
  public var variableProps: VariableProps? {
    didSet {
      if let props = self.variableProps {
        self.didSetProps(props)
      }
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.counterTF.isEnabled = false
    self.stringTF1.isEnabled = false
    self.slideTF.isEnabled = false
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Reload table",
      style: .plain,
      target: self,
      action: #selector(self.reloadTable))
  }
  
  private func didSetProps(_ props: VariableProps) {
    self.counterTF.text = props.nextState.number.map(String.init)
    self.slideTF.text = props.nextState.slider.map(String.init)
    self.stringTF1.text = props.nextState.string
    self.stringTF2.text = props.nextState.string
    self.valueSL.value = props.nextState.slider ?? valueSL.minimumValue
  }
  
  @IBAction func incrementNumber(_ sender: UIButton) {
    self.variableProps?.dispatch.incrementNumber()
  }
  
  @IBAction func decrementNumber(_ sender: UIButton) {
    self.variableProps?.dispatch.decrementNumber()
  }
  
  @IBAction func updateString(_ sender: UITextField) {
    self.variableProps?.dispatch.updateString(sender.text)
  }
  
  @IBAction func updateSlider(_ sender: UISlider) {
    self.variableProps?.dispatch.updateSlider(Double(sender.value))
  }
  
  @objc func reloadTable(_ sender: UIBarButtonItem) {
    self.textTable.reloadData()
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return self.variableProps?.nextState.texts?.count ?? 10
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView
      .dequeueReusableCell(withIdentifier: "TableCell")
      as! TableCell

    cell.textIndex = indexPath.row
    _ = self.staticProps?.connector.connect(view: cell, mapper: cell)
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
}

extension ViewController {
  struct StateProps {
    public var number: Int? = nil
    public var slider: Float? = nil
    public var string: String? = nil
    public var texts: [String?]? = nil
  }
  
  struct DispatchProps {
    let incrementNumber: () -> Void
    let decrementNumber: () -> Void
    let updateSlider: (Double) -> Void
    let updateString: (String?) -> Void
  }
}

extension ViewController.StateProps: Equatable {}
extension ViewController.StateProps: Decodable {}
extension ViewController: ReduxCompatibleViewType {}
