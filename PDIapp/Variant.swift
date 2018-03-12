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
 * PURPOSE: Is an object that builds the configuration of a variant
 */
class Variant
{
    var num = "123_456"
    var message: String!
    
    init(numIn: String, messageIn: String)
    {
        num = numIn
        message = messageIn
    }
}
