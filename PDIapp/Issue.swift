//
//  Issue.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/19/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: Issue
 * PURPOSE: Issue is an object that holds all of the information pertaining to a given Issue
 */
class Issue
{
    var id: String!
    var issueDescription: String!
    var status = 2
    var user = "none assigned"
    var image: Data!
    var imageId: String!
    
    init(idIn: String, issueDescriptionIn: String)
    {
        id = idIn
        issueDescription = issueDescriptionIn
    }
}
