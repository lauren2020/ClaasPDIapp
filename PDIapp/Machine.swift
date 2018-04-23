//
//  Machine.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/9/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: Machine
 * PURPOSE: Machine is an object that holds all of the information pertaining to a given machine
 */
class Machine
{
    //_id
    var id: String!
    //machineId
    var name: String!
    var thisPDI: PDI!
    var configuration = [String?]()
    var po2Config = 0764
    var completedBy: String!
    
    init(name: String)
    {
        self.name = name
    }

    func addPDI(pdiIn: PDI)
    {
        thisPDI = pdiIn
    }
}
