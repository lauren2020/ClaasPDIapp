//
//  PDI.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/10/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

/*
 * CLASS: PDI
 * PURPOSE: Is an object that builds the configuration of a PDI
 */
class PDI
{
    var initialFuelConsumption: Double!
    var finalFuelConsumption: Double!
    var name: String!
    
    var OMMain = ""
    var OMSupp = ""
    var OMFitting = ""
    var OMCemos = ""
    var OMTeraTrack = ""
    var OMProfiCam = ""
    
    //Hold battery entries
    //[0] = CCA, [1] = Volt
    var C13 = ["",""]
    var G001 = ["",""]
    var G005 = ["",""]
    var G004 = ["",""]
    var MAN1 = ["",""]
    var MAN2 = ["",""]
    var completedBy: String!
    
    //0 = Incomplete, 1 = In Progress, 2 = Complete
    var status = 0
    //Keeps track of what question is currently being processed
    var thisQuestion = 0
    
    //Holds all checkpoints for current machine pdi, imported from DB
    var checkpointBank = [Checkpoint]()
    //Holds all variants for current machine pdi, imported from DB
    var variantBank = [Variant!]()
    //Holds responses to checkpoints
    //0 = not answered, 1 = ok, 2 = notOk, 3 = N/A
    var questionResponseBank = [Int]()
    //Holds responses to variants
    //0 = not answered, 1 = ok, 2 = notOk
    var variantResponseBank = [Int]()
    var quesitonIssueBank = [String]()
    
    var skipped: [Variant]!
    var skippedPos: [Int]!
    var skippedResponseBank: [Int]!
    var currentSkipped = 0;
    var noSkippedVariants = false
    var noSkippedCheckpoints = false
    
    
    init(name: String)
    {
        self.name = name
    }
    
    func setInitialFuelConsumption(fuelConsumptionIn: Double)
    {
        initialFuelConsumption = fuelConsumptionIn
    }
    func setFinalFuelConsumption(fuelConsumptionIn: Double)
    {
        finalFuelConsumption = fuelConsumptionIn
    }
    func setStatus(statusIn: Int)
    {
        status = statusIn
    }
    func getResponse(question: Int) -> Int
    {
        return questionResponseBank[question]
    }
    func setQuestionBank(arrayIn: [Checkpoint])
    {
        checkpointBank.removeAll()
        if(arrayIn.count != 0)
        {
            for index in 0..<arrayIn.count{
                checkpointBank.append(arrayIn[index])
            }
        }
        for _ in 0..<checkpointBank.count
        {
            questionResponseBank.append(0)
        }
    }
    func setVariantBank(arrayIn: [Variant])
    {
        variantBank.removeAll()
        if(arrayIn.count != 0)
        {
            for index in 0...arrayIn.count - 1{
                variantBank.append(arrayIn[index])
            }
            for _ in 0...variantBank.count - 1
            {
                variantResponseBank.append(0)
            }
        }
       /* for _ in 0...variantBank.count - 1
        {
            variantResponseBank.append(0)
        }*/
    }
}
