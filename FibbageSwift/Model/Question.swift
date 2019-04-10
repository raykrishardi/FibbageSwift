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
    let answer: String
    let bluff1: String
    let bluff2: String
    
    init(text: String, answer: String, bluff1: String, bluff2: String) {
        self.text = text
        self.answer = answer
        self.bluff1 = bluff1
        self.bluff2 = bluff2
    }
    
}
