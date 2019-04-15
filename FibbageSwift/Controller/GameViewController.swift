//
//  ViewController.swift
//  FibbageSwift
//
//  Created by Ray Krishardi Layadi on 4/4/19.
//  Copyright © 2019 Ray Krishardi Layadi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SVProgressHUD

class GameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: - Class-level variable
    var player1: String?
    var player2: String?
    var playerBluff = ""
    
    var getUserInputTimer: Timer?
    let GET_USER_INPUT_TIME_INTERVAL = 10.0
    
    var questions: [Question] = []
    var questionIndex = 0
    let TOTAL_NUM_OF_QUESTIONS = 5
    var score = 0
    var selectedAnswer = ""

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getQuestionText()
    }
    
    // MARK: - viewDidAppear()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getUserInput()
        
        getUserInputTimer = Timer.scheduledTimer(withTimeInterval: GET_USER_INPUT_TIME_INTERVAL, repeats: false) { (timer) in
            self.submitPlayerBluff()
        }
        
    }
    
    func getQuestionText() {
        let db = Firestore.firestore()
        
        db.collection("questions").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            for document in documents {
                self.questions.append(Question(text: document["text"] as! String))
            }
            
            self.updateUI()
        }
    }
    
    func setQuestionAnswers() {
        let db = Firestore.firestore()
        
        db.collection("questions").document("question\(questionIndex+1)").getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching document: \(error!)")
                return
            }
            
            if let playerBluff1 = document[self.player1!] as? [String: String], let playerBluff2 = document[self.player2!] as? [String: String] {
                
                self.questions[self.questionIndex].setAnswers(answer: document["answer"] as! String, bluff: document["bluff"] as! String, playerBluff1: playerBluff1["playerBluff"]!, playerBluff2: playerBluff2["playerBluff"]!)
                
                print("***\n\(self.questions[self.questionIndex].answers)\n***")
                
                self.setupPickerView() // If called in viewDidLoad then will crash (index out of range)
//                self.updateUI()

            } else {
                SVProgressHUD.show(withStatus: "Waiting for the opponent to enter a bluff")

                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (timer) in
                    print("Opponent has not entered a bluff")
                    SVProgressHUD.dismiss()
                    self.setQuestionAnswers()
                })
            }
            
            
        }
        
    }
    
    // MARK: - UIAlertController
    func getUserInput() {
        let alertController = UIAlertController(title: "Enter a bluff", message: questions[questionIndex].text, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Bluff"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            let textField = alertController.textFields![0] as UITextField
            
            // TODO: Process user input
            self.playerBluff = textField.text!
            self.getUserInputTimer?.invalidate()
            
            self.submitPlayerBluff()

        }
        
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addPlayerBluffToFirestore() {
        let db = Firestore.firestore()
        
        db.collection("questions").document("question\(questionIndex+1)").setData([player1!: ["playerBluff": playerBluff]], merge: true)
    }
    
    func submitPlayerBluff() {
        addPlayerBluffToFirestore()
        dismiss(animated: true, completion: nil) // Dismiss UIAlertController when the timer ends
        setQuestionAnswers()
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
        return questions[questionIndex].answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return questions[questionIndex].answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAnswer = questions[questionIndex].answers[row]
        print(selectedAnswer)
    }
    
    func updateUI() {
        questionLabel.text = questions[questionIndex].text
        progressLabel.text = "\(questionIndex+1)/\(TOTAL_NUM_OF_QUESTIONS)"
        scoreLabel.text = "Score: \(score)"
        progressView.frame.size.width = (view.frame.size.width / CGFloat(TOTAL_NUM_OF_QUESTIONS)) * CGFloat(questionIndex+1)
    }
    
    // MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: Any) {
        questionIndex += 1
        
        updateUI()
        
        getUserInput()
        
        getUserInputTimer = Timer.scheduledTimer(withTimeInterval: GET_USER_INPUT_TIME_INTERVAL, repeats: false) { (timer) in
            self.submitPlayerBluff()
        }
        
    }
    

}

