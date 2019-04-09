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
        
        setupPickerView()
    }
    
    // MARK: - viewDidAppear()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getUserInput()
    }
    
    // MARK: - Setup UIPickerView data source and delegate
    func setupPickerView() {
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
    
    // MARK: - UIAlertController
    func getUserInput() {
        let alertController = UIAlertController(title: "Enter Bluff", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Bluff"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            let textField = alertController.textFields![0] as UITextField
            
            // TODO: Process user input
            print(textField.text!)
        }
        
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    @IBAction func buttonPressed(_ sender: Any) {
    }
    

}

