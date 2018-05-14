//
//  Checkpoint.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/10/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: Checkpoint
 * PURPOSE: Is an object that builds the configuration of a checkpoint
 */
class Checkpoint
{
    var macPosition: String! //errorPos
    var failure: String! //errorDescription
    var type = [Int()] //Machinetype
    var id: String!
    var position = 0
    var response = 0 //Unanswered
    var skipped = false
    var moreInfo = "MORE INFO GOES HERE"
    var imageURL = "https://dingo.care2.com/pictures/greenliving/1407/1406075.large.jpg"
    //var imageURL = "https://lh3.google.com/u/2/d/1vxBTSi-nc5G6A4a2RhQTUKv4Tkk-EjT0=w2826-h1410-iv1"
    
    init(positionIn: String, failureIn: String, typeIn: [Int], idIn: String)
    {
        macPosition = positionIn
        failure = failureIn
        type = typeIn
        id = idIn
    }
}
