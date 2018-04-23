//
//  PDIView.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/9/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation
import UIKit

/*
 * CLASS: OM
 * PURPOSE: OM is an object that holds all of the information pertaining to a given OMM
 */
class PDIView
{
    var vc: UIViewController!
    var backSegue: String!
    var nextSegue: String!
    var toMainSegue: String!
    
    init(vcIn: UIViewController, backSegueIn: String, nextSegueIn: String, toMainSegueIn: String)
    {
        vc = vcIn
        backSegue = backSegueIn
        nextSegue = nextSegueIn
        toMainSegue = toMainSegueIn
    }
}
