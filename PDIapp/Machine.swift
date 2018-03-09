//
//  Machine.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/9/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation
class Machine
{
    //_id
    var id: String!
    //machineId
    var name: String!
    var thisPDI: PDI! // = PDI(name: "default")//
    var configuration = ["MD_B06_0010", "MD_B10_0037", "MD_B12_0020"]//[String]()
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
