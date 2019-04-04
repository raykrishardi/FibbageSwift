//
//  ViewController.swift
//  FibbageSwift
//
//  Created by Ray Krishardi Layadi on 4/4/19.
//  Copyright © 2019 Ray Krishardi Layadi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: - Class-level variable
    var answers = ["a", "b", "c", "d"]
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerPicker.dataSource = self
        answerPicker.delegate = self
    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate delegate method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedAnswer = answers[row]
        print(selectedAnswer)
    }
    
    // MARK: - IBAction
    @IBAction func buttonPressed(_ sender: Any) {
    }
    

}

