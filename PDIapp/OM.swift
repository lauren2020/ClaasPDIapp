//
//  OM.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/26/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: OM
 * PURPOSE: OM is an object that holds all of the information pertaining to a given OMM
 */
class OM
{
    var dbIdentifier: String!
    var displayName: String!
    var variants = [String!]()
    var response = ""
    var included = false
    var field = 0
    
    init(dbIdentifierIn: String, displayNameIn: String)
    {
        dbIdentifier = dbIdentifierIn
        displayName = displayNameIn
    }
}
