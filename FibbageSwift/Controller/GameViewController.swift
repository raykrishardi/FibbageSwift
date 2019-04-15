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
    var sessionID: String?
    var playerBluff = ""
    
    var getUserInputTimer: Timer?
    let GET_USER_INPUT_TIME_INTERVAL = 10.0
    
    var questions: [Question] = []
    var questionIndex = 0
    let TOTAL_NUM_OF_QUESTIONS = 2
    var player1Score = 0
    var player2Score = 0
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
        answerPicker.selectRow(0, inComponent: 0, animated: false)
        pickerView(answerPicker, didSelectRow: 0, inComponent: 0)
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
        self.selectedAnswer = questions[questionIndex].answers[row]
        print(self.selectedAnswer)
    }
    
    func updateUI() {
        questionLabel.text = questions[questionIndex].text
        progressLabel.text = "\(questionIndex+1)/\(TOTAL_NUM_OF_QUESTIONS)"
        scoreLabel.text = "P1 score: \(self.player1Score)\nP2 score: \(self.player2Score)"
        progressView.frame.size.width = (view.frame.size.width / CGFloat(TOTAL_NUM_OF_QUESTIONS)) * CGFloat(questionIndex+1)
    }
    
    func checkPlayerAnswer() {
        let correctAnswer = questions[questionIndex].answers[0]
//        let defaultBluff = questions[questionIndex].answers[1]
//        let player1Bluff = questions[questionIndex].answers[2]
        let player2Bluff = questions[questionIndex].answers[3]

        let db = Firestore.firestore()
        
        db.collection("players").document(self.player1!).getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching document: \(error!)")
                return
            }
            
            self.player1Score = document["score"] as! Int
        }
        
        db.collection("players").document(self.player2!).getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching document: \(error!)")
                return
            }
            
            self.player2Score = document["score"] as! Int
            
            print("selected answer: \(self.selectedAnswer)")
            print("correct answer: \(correctAnswer)")
            print("player2 bluff: \(player2Bluff)")
            
            switch self.selectedAnswer {
            case correctAnswer:
                self.player1Score += 10
                SVProgressHUD.showSuccess(withStatus: "Correct!")
            case player2Bluff:
                self.player2Score += 5
                SVProgressHUD.showError(withStatus: "Player2 Bluff!")
            default: SVProgressHUD.showError(withStatus: "Incorrect!")
            }
            
            SVProgressHUD.dismiss(withDelay: 1.5)
            
            print("***\nplayer1 score: \(self.player1Score)\n***")
            print("***\nplayer2 score: \(self.player2Score)\n***")
            
            db.collection("players").document(self.player1!).setData(["score": self.player1Score], merge: true)
            db.collection("players").document(self.player2!).setData(["score": self.player2Score], merge: true)
            
            self.questionIndex += 1
            
            if self.questionIndex < self.TOTAL_NUM_OF_QUESTIONS {
                self.updateUI()
                
                // Delay the call by 2 seconds because if not then will overlap with success/error message of SVProgressHUD
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
                    self.getUserInput()
                    
                    self.getUserInputTimer = Timer.scheduledTimer(withTimeInterval: self.GET_USER_INPUT_TIME_INTERVAL, repeats: false) { (timer) in
                        self.submitPlayerBluff()
                    }
                }
            } else {
                print("End of question!")
                self.scoreLabel.text = "P1 score: \(self.player1Score)\nP2 score: \(self.player2Score)"
                
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (timer) in
                    self.promptRestartGame()
                })
                
//                self.prepareToDeleteSession()
                
                
//                db.collection("players").document(self.player1!).setData(["readyToEndSession": true], merge: true)
//
//                db.collection("players").document(self.player2!).addSnapshotListener({ (document, error) in
//                    guard let document = document, document.exists else {
//                        print("Error fetching document: \(error!)")
//                        return
//                    }
//
//                    if document["readyToEndSession"] != nil {
//                        self.deleteSessionAndGameData()
//                    }
//                })
                
            }
        }
        
        
        
    }
    
    func prepareToDeleteSession() {
        let db = Firestore.firestore()
        
        db.collection("players").document(self.player1!).setData(["readyToEndSession": true], merge: true)

        db.collection("players").document(self.player2!).getDocument { (document, error) in
//            guard let document = document, document.exists else {
//                print("Error fetching document: \(error!)")
//                return
//            }
            
            if let document = document, document.exists {
                if document["readyToEndSession"] != nil {
                    self.deleteSessionAndGameData()
                } else {
                    SVProgressHUD.show(withStatus: "Waiting for the opponent to end session")
                    
                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (timer) in
                        print("Opponent not ready to end session")
                        SVProgressHUD.dismiss()
                        self.prepareToDeleteSession()
                    })
                }
            } else {
                self.deleteSessionAndGameData()
            }
            

        }
        
    }
    
    func deleteSessionAndGameData() {
        let db = Firestore.firestore()
        
        db.collection("players").document(self.player1!).delete { (error) in
            if let error = error {
                print("Error removing player document: \(error)")
            } else {
                print("Player document successfully removed!")
            }
        }
        
        for i in 1...self.TOTAL_NUM_OF_QUESTIONS {
            db.collection("questions").document("question\(i)").updateData([self.player1!: FieldValue.delete()]) { (error) in
                if let error = error {
                    print("Error removing question field: \(error)")
                } else {
                    print("Question field successfully removed!")
                }
            }
        }
        
        db.collection("sessions").document(self.sessionID!).getDocument { (document, error) in
            if let document = document, document.exists {
                db.collection("sessions").document(self.sessionID!).delete()
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func promptRestartGame() {
        let alert = UIAlertController(title: "End of quiz", message: "Would you like to restart?", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (UIAlertAction) in
            self.prepareToDeleteSession()
        }
        
        alert.addAction(restartAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.playerBluff = ""
        
        checkPlayerAnswer()
        

        

        
    }
    

}

