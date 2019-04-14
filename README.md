# FibbageSwift
Swift implementation of Fibbage 3 game by Jackbox Games

Note:
1. Need to perform these when application is terminated or game has finished
    * FireStore
        * Need to remove the active session document from "sessions" collection
        * Need to remove each player from "players" collection
        * Need to remove each player bluff from each question in "questions" collection
    
