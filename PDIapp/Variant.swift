//
//  Variant.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: Variant
 * PURPOSE: Is an object that holds all the information within a given variant
 */
class Variant
{
    var num = "123_456"
    var message: String!
    var id = "s233jfkf345kk"
    var listPosition = 0
    var response = 0 //Unanswered
    var skipped = false
    var moreInfo = "MORE INFO GOES HERE"
    var imageURL = "https://dingo.care2.com/pictures/greenliving/1407/1406075.large.jpg"
    
    init(numIn: String, messageIn: String)
    {
        num = numIn
        message = messageIn
    }
}
