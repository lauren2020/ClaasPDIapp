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
    var position: String! //errorPos
    var failure: String! //errorDescription
    var type = [Int()] //Machinetype
   // var status: UInt64!
    var id: String!
    var moreInfo = "MORE INFO GOES HERE"
    var imageURL = "https://dingo.care2.com/pictures/greenliving/1407/1406075.large.jpg"
   // var errorNr: Int!
    
    init(positionIn: String, failureIn: String, typeIn: [Int], idIn: String)
    {
        position = positionIn
        failure = failureIn
        type = typeIn
        id = idIn
       // errorNr = errorNrIn
        //status = statusIn
    }
}
