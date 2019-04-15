//
//  Question.swift
//  FibbageSwift
//
//  Created by Ray Krishardi Layadi on 10/4/19.
//  Copyright © 2019 Ray Krishardi Layadi. All rights reserved.
//

import Foundation

class Question {
    let text: String
    var answers: [String] = []
    
    init(text: String) {
        self.text = text
    }
    
    func setAnswers(answer: String, bluff: String, playerBluff1: String, playerBluff2: String) {
        self.answers.append(answer)
        self.answers.append(bluff)
        self.answers.append(playerBluff1)
        self.answers.append(playerBluff2)
    }
    
}
