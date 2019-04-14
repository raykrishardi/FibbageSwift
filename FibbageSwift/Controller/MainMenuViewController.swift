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
    var opponentFound = false
    
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
        
        db.collection("players").document(player1!).setData(["playerID": player1!, "opponent": ""], merge: true)
        
        print("***\nSuccessfully added a new user to FireStore\n***")
        
        checkExistingOpponent()
//        getNewOpponent()
        

    }
    
    func checkExistingOpponent() {
        let db = Firestore.firestore()
        
        db.collection("sessions").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            
            for document in documents {
                
                let p1 = document["player1"] as! String
                let p2 = document["player2"] as! String
                
                let hasActiveSession = (p1 == self.player1 || p2 == self.player1)
                
                if hasActiveSession {
                    print("***\nOpponent found!\n***")
                    self.opponentFound = true
                    
                    // TODO: Set player 2 from the session by checking the player ID to player1 ID
                    self.player2 = (p1 == self.player1) ? self.player2 : self.player1
                    
                    db.collection("players").document(self.player1!).setData(["opponent": self.player2!], merge: true)
                    
                    self.performSegue(withIdentifier: "goToBluff", sender: self)
                    SVProgressHUD.dismiss()
                }
                
            }
            
            if !self.opponentFound {
                print("***\nOpponent NOT found!\n***")
                
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { (timer) in
                    self.searchOpponent()
                })
            }
            
            
        }
    }
    
//    func getNewOpponent() {
//        let db = Firestore.firestore()
//
//        db.collection("players").document(player1!).getDocument { (document, error) in
//            if let error = error {
//                print("Error fetching document: \(error)")
//            } else {
//                let opponent = document!["opponent"] as! String
//
//                print(opponent)
//
//                if opponent == "" {
//                    print("No opponent yet, searching for player...")
//                    self.searchOpponent()
//                } else {
//                    print("***\nOpponent found!\n***")
//                    self.opponentFound = true
//
//                    self.player2 = opponent
//
//                    self.performSegue(withIdentifier: "goToBluff", sender: self)
//                    SVProgressHUD.dismiss()
//                }
//
//            }
//        }
//    }
    
    // TODO: Add player ID to a new session
    @objc func searchOpponent() {
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
                    let opponent = document["opponent"] as! String
                
                    if playerID != self.player1 && opponent == "" {
                        
                        self.opponentFound = true
                        
                        self.player2 = playerID
                        print("***\nOpponent ID: \(self.player2!)\n***")
                        
                        // TODO: Set "searchingForOpponent" to false in FireStore
                        
                        db.collection("sessions").addDocument(data: ["player1": self.player1!, "player2": self.player2!])
                        
                        db.collection("players").document(self.player1!).setData(["opponent": self.player2!], merge: true)
//                        db.collection("players").document(self.player2!).setData(["opponent" : self.player1!], merge: true)
                        

                        
                        self.performSegue(withIdentifier: "goToBluff", sender: self)
                        SVProgressHUD.dismiss()
                        
                        
                        break
                    }
                }
                
                if !self.opponentFound {
                    print("***\nOpponent NOT found after searching!\n***")
                    
                    Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false, block: { (timer) in
                        self.checkExistingOpponent()
                    })
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
    
}
