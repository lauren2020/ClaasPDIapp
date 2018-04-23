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
 * PURPOSE: Is an object that builds that holds all of the information within a given machine inspection
 */
class PDI
{
    var initialFuelConsumption: Double!
    var finalFuelConsumption: Double!
    var name: String!
    
    var omBank = [OM(dbIdentifierIn: "ommMain", displayNameIn: "OMM Main"), OM(dbIdentifierIn: "ommSupp", displayNameIn: "OMM Supp"), OM(dbIdentifierIn: "ommUnload", displayNameIn: "OMM Unload")]
    var OMMain = ""
    var OMSupp = ""
    var OMFitting = ""
    var OMCemos = ""
    var OMTeraTrack = ""
    var OMProfiCam = ""
    var OMTouch = ""
    var OMDual = ""
    var position = "ifc"
    var vcs = [PDIView(vcIn: FuelConsumptionViewController(), backSegueIn: "none", nextSegueIn: "FCtoBattery", toMainSegueIn: "fcCancelToMain"), PDIView(vcIn: batteryViewController(), backSegueIn: "batteryBackToFC", nextSegueIn: "batteryToOm", toMainSegueIn: "batteryCancelToMain"), PDIView(vcIn: OMViewController(), backSegueIn: "OMBackToBattery", nextSegueIn: "omToVariants", toMainSegueIn: "omCancelToMain"), PDIView(vcIn: VariantsViewController(), backSegueIn: "VariantsBackToOM", nextSegueIn: "variantsToCheckpoint", toMainSegueIn: "variantsCancelToMain"), PDIView(vcIn: PDIViewController(), backSegueIn: "CheckpointsBackToVariants", nextSegueIn: "checkpointsToFinalFC", toMainSegueIn: "checkpointsCancelToMain"), PDIView(vcIn: FinalFCViewController(), backSegueIn: "FFCBackToCheckpoints", nextSegueIn: "none", toMainSegueIn: "ffcToMain")]
   // var vcs = [FuelConsumptionViewController(), batteryViewController(), OMViewController(), VariantsViewController(), PDIViewController(), FinalFCViewController()]
   // var segue = ["FCtoBattery", "batteryToOm", "omToVariants", "variantsToCheckpoint", "checkpointsToFinalFC"]
    
    var hasCemos = false
    var hasTeraTrack = false
    var hasProfiCam = false
    var hasTouch = false
    var hasDual = false
    
    //Hold battery entries
    //[0] = CCA, [1] = Volt
    var C13 = ["",""]
    var G001 = ["",""]
    var G005 = ["",""]
    var G004 = ["",""]
    var MAN1 = ["",""]
    var MAN2 = ["",""]
    var batteryIssues = [Array<String>()]
    var completedBy = "name"
    
    var newIssuesBank = [Issue!]()
    
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
    var questionIssueBank = [Checkpoint]()
    var variantIssueBank = [Variant]()
    
    var skippedVariantBank = [SkippedVariant]()
    var skippedCheckpointBank = [SkippedCheckpoint]()
    
    var currentSkipped = 0;
    var noSkippedVariants = false
    var noSkippedCheckpoints = false
    
    
    init(name: String)
    {
        self.name = name
        omBank[0].included = true
        omBank[1].included = true
        omBank[2].included = true
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
    }
}
