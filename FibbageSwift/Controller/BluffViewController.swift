//
//  BluffViewController.swift
//  FibbageSwift
//
//  Created by Ray Krishardi Layadi on 10/4/19.
//  Copyright © 2019 Ray Krishardi Layadi. All rights reserved.
//

import UIKit
import FirebaseFirestore

class BluffViewController: UIViewController {
    
    // MARK: - Class-level variable
    var player1: String?
    var player2: String?
    var playerBluff = ""
    var getUserInputTimer: Timer?
    let GET_USER_INPUT_TIME_INTERVAL = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - viewDidAppear()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getUserInput()
        
        getUserInputTimer = Timer.scheduledTimer(withTimeInterval: GET_USER_INPUT_TIME_INTERVAL, repeats: false) { (timer) in
            
            
            self.addPlayerBluffToFirestore()
            self.displayGameView()
        }
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
            self.playerBluff = textField.text!
            self.getUserInputTimer?.invalidate()
            
            self.addPlayerBluffToFirestore()
            self.displayGameView()
            
        }
        
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addPlayerBluffToFirestore() {
        let db = Firestore.firestore()
        
        db.collection("questions").document("question1").setData([player1!: ["playerBluff": playerBluff]], merge: true)
    }
    
    func displayGameView() {
        self.dismiss(animated: true, completion: nil) // Dismiss UIAlertController when the timer ends
        self.performSegue(withIdentifier: "goToGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let destVC = segue.destination as! GameViewController
            
            destVC.player1 = self.player1
            destVC.player2 = self.player2
            destVC.playerBluff = self.playerBluff
        }
    }

}
