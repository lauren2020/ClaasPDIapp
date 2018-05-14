//
//  exportData.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation
import MongoKitten

/*
 * CLASS: exportData
 * PURPOSE: Is an object that builds the configuration of a port for sending data back to the database
 */
class exportData
{
    //Machine PDI is being performed on
    var db: Database!
    var server: Server!
    var targetMachine: Machine!
    var questionIssues = [String()]
    var variantIssues = [String()]
    var issuesArray = [Any]()
    
    init(machineIn: Machine)
    {
        targetMachine = machineIn
        do
        {
        server = try Server("mongodb://ClaasQualityCOL:s8umftog_34TA1@cluster0-shard-00-00-2a366.gcp.mongodb.net:27017,cluster0-shard-00-01-2a366.gcp.mongodb.net:27017,cluster0-shard-00-02-2a366.gcp.mongodb.net:27017/sandbox?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
        db = server["sandbox"]
        if server.isConnected {
            print("Connected to database!")
        }
        }
        catch{
            print(error)
        }
    }
    /*
     * FUNCTION: createInspected
     * PURPOSE: Adds a new object to collection "inspectedMachines" in DB for current machine
    */
    func createInspected()
    {
        do
        {
            if(!inspectedExists(macName: targetMachine.name))
            {
            let inspectedMacs = db["inspectedMachines"]
            let newMachine: Document = [
                "machineId":  targetMachine.name,
                "active": 1,
                "pdiPosition": "ifc",
                ]
             try inspectedMacs.insert(newMachine)
            }
            else{
                setActiveStatus(activeStat: 1)
            }
        }
        catch{
            print(error)
        }
        
        print("INSPECTED MACHINE OBJECT CREATED FOR MACHINE ", targetMachine.name)
    }
    func inspectedExists(macName: String) -> Bool
    {
        var exists = false
        var count = 0
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == macName)
            {
                count += 1
            }
        }
        catch
        {
            print(error)
        }
        if(count > 0)
        {
            exists = true
        }
        return exists
    }
    /*
     * FUNCTION: removeInspected
     * PURPOSE: Removes object from collection "inspectedMachines" in DB for machine whose pdi is being canceled.
     */
    func removeInspected()
    {
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            try inspectedMacs.remove("machineId" == targetMachine.name)
        }
        catch{
            print(error)
        }
        print("INSPECTED MACHINE OBJECT REMOVED FOR MACHINE ", targetMachine.name)
    }
    /*
     * FUNCTION: pushResults
     * PURPOSE: Pushes results from machines pdi to collection "inspectedMachines" in DB
     */
    func pushResults()
    {
        print("ALL DATA EXPORTED")
        print("Name: ", targetMachine.thisPDI.name)
        pushInitialFuelConsumption()
        pushBattery()
        pushOM()
        pushCheckpoints()
        pushFinalFuelConsumption()
    }
    func pushInitialFuelConsumption()
    {
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            
            try inspectedMacs.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "fuelBefore": targetMachine.thisPDI.initialFuelConsumption
                ]
                ])
        }
        catch{
            print(error)
        }
        print("INITIAL FUEL CONSUMPTION EXPORTED")
        print("Initial Fuel Consumption: ", targetMachine.thisPDI.initialFuelConsumption)
    }
    func pushBattery()
    {
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            
            if(targetMachine.po2Config >= 0700 && targetMachine.po2Config <= 0799)
            {
                //mercedesConfig()
                try inspectedMacs.update("machineId" == targetMachine.name, to: [
                    "$set": [
                        "g001CCA": targetMachine.thisPDI.G001[0],
                        "g001Volt": targetMachine.thisPDI.G001[1],
                        "g005CCA": targetMachine.thisPDI.G005[0],
                        "g005Volt": targetMachine.thisPDI.G005[1],
                        "g004CCA": targetMachine.thisPDI.G004[0],
                        "g004Volt": targetMachine.thisPDI.G004[1]
                    ]
                    ])
            }
            if(targetMachine.po2Config >= 0600 && targetMachine.po2Config <= 0699)
            {
                //c13Config()
                try inspectedMacs.update("machineId" == targetMachine.name, to: [
                    "$set": [
                        "c13CCA": targetMachine.thisPDI.C13[0],
                        "c13Volt": targetMachine.thisPDI.C13[1]
                    ]
                    ])
            }
            if(targetMachine.po2Config >= 0900 && targetMachine.po2Config <= 0999)
            {
                //manConfig()
                try inspectedMacs.update("machineId" == targetMachine.name, to: [
                    "$set": [
                        "man1CCA": targetMachine.thisPDI.MAN1[0],
                        "man1Volt": targetMachine.thisPDI.MAN1[1],
                        "man2CCA": targetMachine.thisPDI.MAN2[0],
                        "man2Volt": targetMachine.thisPDI.MAN2[1]
                    ]
                    ])
            }
        }
        catch
        {
            print(error)
        }
        print("BATTERY INFO EXPORTED")
        print("Battery Fields: ", targetMachine.thisPDI.C13[0], " ", targetMachine.thisPDI.C13[1])
        print(targetMachine.thisPDI.G001[0], targetMachine.thisPDI.G001[1])
        print(targetMachine.thisPDI.G004[0], targetMachine.thisPDI.G004[1])
        print(targetMachine.thisPDI.G005[0], targetMachine.thisPDI.G005[1])
        print(targetMachine.thisPDI.MAN1[0], targetMachine.thisPDI.MAN1[1])
        print(targetMachine.thisPDI.MAN2[0], targetMachine.thisPDI.MAN2[1])
    }
    func pushOM()
    {
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            
            try inspectedMacs.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "mainOMM": targetMachine.thisPDI.OMMain,
                    "suppOMM": targetMachine.thisPDI.OMSupp,
                    "fittingOMM": targetMachine.thisPDI.OMFitting,
                    "cemosOMM": targetMachine.thisPDI.OMCemos,
                    "teraTrackOMM": targetMachine.thisPDI.OMTeraTrack,
                    "profiCam": targetMachine.thisPDI.OMProfiCam
                ]
                ])
        }
        catch{
            print(error)
        }
        print("OM INFO EXPORTED")
        print("OM Main: ", targetMachine.thisPDI.OMMain)
        print("OM Supp: ", targetMachine.thisPDI.OMSupp)
        print("OM Fitting: ", targetMachine.thisPDI.OMFitting)
        print("OM Cemos: ", targetMachine.thisPDI.OMCemos)
        print("OM Tera Track: ", targetMachine.thisPDI.OMTeraTrack)
        print("OM ProfiCam: ", targetMachine.thisPDI.OMProfiCam)
        print("OM INFO EXPORTED")
    }
    func pushVariants()
    {
        print("VARIANTS EXPORTED")
        for index in 0 ..< targetMachine.thisPDI.variantBank.count
        {
            print(targetMachine.thisPDI.variantBank[index].num)
            print(targetMachine.thisPDI.variantBank[index].message)
            print(targetMachine.thisPDI.variantResponseBank[index])
        }
    }
    func pushCheckpoints()
    {
        var label: String!
        var issue: String!
        questionIssues = [String()]
        variantIssues = [String()]
        
        for index in 0..<targetMachine.thisPDI.questionResponseBank.count{
            if(targetMachine.thisPDI.questionResponseBank[index] == 2)
            {
                label = targetMachine.thisPDI.checkpointBank[index].id
                issue = targetMachine.thisPDI.checkpointBank[index].failure
                let add = label + ": " + issue
                questionIssues.append(add)
            }
        }
        for index in 0..<targetMachine.thisPDI.variantResponseBank.count{
            if(targetMachine.thisPDI.variantResponseBank[index] == 2)
            {
                label = targetMachine.thisPDI.variantBank[index].num
                issue = targetMachine.thisPDI.variantBank[index].message
                let add = label + ": " + issue
                variantIssues.append(add)
            }
        }
        
        issuesArray = [variantIssues, questionIssues]
        
        
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            
                    try inspectedMacs.update("machineId" == targetMachine.name, to: [
                        "$set": [
                            "issues": issuesArray
                        ]
                        ])
            }
            catch{
                print(error)
            }
            //}
        print("CHECKPOINTS EXPORTED")
        for index in 0 ..< targetMachine.thisPDI.checkpointBank.count
        {
            print(targetMachine.thisPDI.checkpointBank[index].position)
            print(targetMachine.thisPDI.checkpointBank[index].failure)
            print(targetMachine.thisPDI.questionResponseBank[index])
        }
        for index in 0...targetMachine.thisPDI.questionResponseBank.count - 1
        {
            if(targetMachine.thisPDI.questionResponseBank[index] == 2)
            {
                targetMachine.thisPDI.quesitonIssueBank.append(targetMachine.thisPDI.checkpointBank[index].failure)
            }
        }
        //push issue bank
    }
    func pushFinalFuelConsumption()
    {
        do
        {
            let inspectedMacs = db["inspectedMachines"]
            
            try inspectedMacs.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "fuelAfter": targetMachine.thisPDI.finalFuelConsumption
                ]
                ])
        }
        catch{
            print(error)
        }
        print("FINAL FUEL CONSUMPTION EXPORTED")
        print("Final Fuel Consumption: ", targetMachine.thisPDI.finalFuelConsumption)
    }
    /*
     * FUNCTION: macStatus
     * PURPOSE: Changes status field of object in collection "machinesReadyToGo" in DB for current machine
     * PARAMS: status - value that status will be changed to
     */
    func macStatus(status: Int)
    {
        do
        {
            let machinesReady = db["machineReadyToGo"]
            
            try machinesReady.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "pdiStatus": status
                ]
                ])
        }
        catch{
            print(error)
        }
        print("MACHINE STATUS SET TO ", status)
    }
    func sendMessageToWashBay(message: String)
    {
        do
        {
            let washBay = db["washBayText"]
            
            let newMessage: Document = [
                "machineNr":  targetMachine.name,
                "washBayMessage":  message,
                "active":  0,
                "user":  targetMachine.completedBy,
                ]
            try washBay.insert(newMessage)
        }
        catch{
            print(error)
        }
    }
    func addIssue(issue: String)
    {
        targetMachine.thisPDI.quesitonIssueBank.append(issue)
    }
    func setReturnPos(pos: String)
    {
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            try inspectedMachines.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "pdiPosition": pos
                ]
                ])
        }
        catch{
            print(error)
        }
    }
    func setActiveStatus(activeStat: Int)
    {
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            try inspectedMachines.update("machineId" == targetMachine.name, to: [
                "$set": [
                    "active": activeStat
                ]
                ])
        }
        catch{
            print(error)
        }
    }
}
