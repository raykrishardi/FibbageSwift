//
//  ViewController.swift
//  FibbageSwift
//
//  Created by Ray Krishardi Layadi on 10/4/19.
//  Copyright © 2019 Ray Krishardi Layadi. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import FirebaseFirestore

class MainMenuViewController: UIViewController {
    
    // MARK: - Class-level variable
    var player1: String?
    var player2: String?
    var sessionActive: Bool = false {
        didSet {
            if sessionActive {
//                searchPlayerTimer?.invalidate()
//                searchSessionTimer?.invalidate()
                performSegue(withIdentifier: "goToBluff", sender: self)
                SVProgressHUD.dismiss()
                
//                searchPlayerTimer?.invalidate()
            } else {
                
                getSession()
                searchPlayer()
                
//                searchSessionTimer = Timer.scheduledTimer(timeInterval: SEARCH_SESSION_TIME_INTERVAL, target: self, selector: #selector(), userInfo: nil, repeats: true)
//
//                // Search another player every 5 seconds
//                searchPlayerTimer = Timer.scheduledTimer(timeInterval: SEARCH_PLAYER_TIME_INTERVAL, target: self, selector: #selector(searchPlayer), userInfo: nil, repeats: true)
            }
        }
    }
//    var searchPlayerTimer: Timer?
//    let SEARCH_PLAYER_TIME_INTERVAL = 5.0
//
//    var searchSessionTimer: Timer?
//    let SEARCH_SESSION_TIME_INTERVAL = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        anonymousSignIn()
    }
    
    // MARK: - Firebase Auth (Anonymous sign-in)
    func anonymousSignIn() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print(error)
            } else {
                self.player1 = Auth.auth().currentUser!.uid
                print("***\nSigned in anonymously...\nUser UID: \(String(describing: self.player1!))\n***")
                self.addPlayerToFirestore()
            }
        }
    }
    
    // MARK: - Firebase Firestore (Add data)
    func addPlayerToFirestore() {
        let db = Firestore.firestore()
        
        db.collection("players").document(player1!).setData(["playerID": player1!, "searchingForOpponent": true], merge: true)
        
        print("***\nSuccessfully added a new user to FireStore\n***")
        
        getSession()
        
    }
    
    @objc func getSession() {
        let db = Firestore.firestore()
        
        db.collection("sessions").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error retrieving sessions: \(error)")
            } else {
                
                let documents = querySnapshot!.documents
                
                if documents.count == 0 {
                    self.sessionActive = false
                } else {
                    for document in documents {
                        if let player1 = document["player1"] as? String {
                            self.player2 = (player1 != self.player1) ? document["player2"] as! String : player1
                            self.sessionActive = true
                            
                            break
                        }
                    }
                }
                
                

            }
        }
        
    }
    
    @objc func searchPlayer() {
        print("Searching another player...")
        
        let db = Firestore.firestore()
        
        db.collection("players").getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            if documents.count >= 2 {
                for document in documents {
                    let playerID = document["playerID"] as! String
                    let isSearchingForOpponent = document["searchingForOpponent"] as! Bool
                
                    if playerID != self.player1 && isSearchingForOpponent {
                        self.player2 = playerID
                        print("***\nOpponent ID: \(self.player2!)\n***")
                        
                        // TODO: Set "searchingForOpponent" to false in FireStore
                        db.collection("players").document(self.player1!).setData(["searchingForOpponent": false], merge: true)
                        db.collection("players").document(self.player2!).setData(["searchingForOpponent" : false], merge: true)
                        
                        // Create a new "sessions" collection for player 1 and player 2
                        db.collection("sessions").addDocument(data: ["player1": self.player1!,"player2": self.player2!])
                        
                        self.sessionActive = true

                        break
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBluff" {
            let destVC = segue.destination as! BluffViewController
            
            destVC.player1 = self.player1
            destVC.player2 = self.player2
            
        
        }
    }
    

    
    // MARK: - Firebase Firestore (Retrieve data)
//    func retrieveData() {
//        let db = Firestore.firestore()
//
//        db.collection("questions").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                for document in querySnapshot!.documents {
//                    let questionDictionary = document.data() as! Dictionary<String,String>
//
//                    if let questionText = questionDictionary["question"] {
//
//                        self.questions.append(Question(text: questionText, answer: questionDictionary["answer"]!, bluff1: questionDictionary["bluff1"]!, bluff2: questionDictionary["bluff2"]!))
//
//                    }
//
//
//                }
//            }
//        }
//    }

}
