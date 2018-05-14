//
//  importData.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation
import MongoKitten

/*
 * CLASS: exportData
 * PURPOSE: Is an object that builds the configuration of a port for getting data from the database
 */
class importData
{
    var db: Database!
    var server: Server!
    var connectionSuccesful: Bool!
    
    var filePath = Bundle.main.url(forResource: "machineBin", withExtension: "txt")!
    var proccessString: String!
    var name: String!
    var rawArray = [String]()
    var splitArray = [String]()
    var tempId: String!
    
    /***********************Fill Checkpoints Params*************************/
    var cpArray = [Checkpoint]()
    //Remove - Checkpoint object needs to be modified
    var tempStatus: Int!
    var tempMachineType: Int!
    var tempErrNr: Int!
    //
    var tempErrorDescription: String!
    var tempErrorPos: String!
    /***********************Fill Machines Params*************************/
    var machineArray = [Machine]()
    var tempName: String!
    /***********************Fill Variants Params*************************/
    var variantArray = [Variant]()
    var tempNum: String!
    var tempMessage: String!
    
    
    
    init(nameIn: String)
    {
        name = nameIn
        do
        {
            server = try Server("mongodb://ClaasQualityCOL:s8umftog_34TA1@cluster0-shard-00-00-2a366.gcp.mongodb.net:27017,cluster0-shard-00-01-2a366.gcp.mongodb.net:27017,cluster0-shard-00-02-2a366.gcp.mongodb.net:27017/sandbox?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
            db = server["sandbox"]
            if server.isConnected {
                print("Connected to database!")
                connectionSuccesful = true
            }
            else
            {
                print("Server could not connect")
                connectionSuccesful = false
            }
        }
        catch{
            print(error)
        }
    }
    
    
    /* Function: fillMachines
     *  Purpose: fills machineArray with Machine objects from raw machine data
     */
    func fillMachines(type: Int)
    {
        machineArray.removeAll()
        var count = 0;
        if(server != nil && server.isConnected)
        {
        do
        {
            
            let machinesReady = db["machineReadyToGo"]
            
            for document in try machinesReady.find("pdiStatus" == type)
            {
                //get name
                let newMachineName = document.arrayRepresentation[document.keys.index(of: "machineId")!]
                let newMachine = Machine(name: newMachineName as! String)
                machineArray.append(newMachine)
                count += 1
            }
            print(count, " MACHINES LOADED SUCCESSFULLY")
        }
        catch{
            print(error)
        }
        }
        else{
            connectionSuccesful = false
        }
    }
    
    /* Function: fillCheckpoints
     *  Purpose: fills checkpointsArray with Checkpoint objects from raw checkpoint data
     */
    func fillCheckpoints(macName: String)
    {
        let macPrefix = macName.prefix(3)
        print("Machine Prefix: ", macPrefix)
        var count = 0;
        do
        {
            let checkpoints = db["checkpoints"]
            let machineType1: Query = "machineType" == String(macPrefix)
            let machineType2: Query = "machineType" == "All Machines"
            for document in try checkpoints.find(machineType1 || machineType2)
            {
                //get name
                let newCPErrorPos = document.arrayRepresentation[document.keys.index(of: "errorPos")!]
                let newCPFailure = document.arrayRepresentation[document.keys.index(of: "errorDescription")!]
                let newCPId = document.arrayRepresentation[document.keys.index(of: "_id")!]
                let newCP = Checkpoint(positionIn: newCPErrorPos as! String, failureIn: newCPFailure as! String, typeIn: [77], idIn: newCPId as! String)
                cpArray.append(newCP)
                count += 1
            }
            print(count, " CHECKPOINTS LOADED SUCCESSFULLY")
        }
        catch{
            print(error)
        }
    }
    
    /* Function: fillVariants
     *  Purpose: fills variantArray with Variant objects from raw variant data
     */
    func fillVariants(macName: String)
    {
        let macPrefix = macName.prefix(3)
        print("Machine Prefix: ", macPrefix)
        var count = 0;
        do
        {
            var thisCollection: String!
            if(macPrefix == "C77")
            {
                thisCollection = "variants_C77"
            }
            else if(macPrefix == "C78")
            {
                thisCollection = "variants_C78"
            }
            else if(macPrefix == "C79")
            {
                thisCollection = "variants_C79"
            }
            else
            {
                //HANDLE NO VARIANTS
            }
            
            let variants = db[thisCollection]
            print("COLLECTION SET")
            
            var storedLabel = "none"
            var storedIssue = "none"
            for document in try variants.find()
            {
                print("ENTERS FOR LOOP 1")
                //get name
                var issueArray = document.arrayRepresentation
                var labelArray = document.keys
                print("Loops: ", labelArray.count)
                for index in 0 ..< labelArray.count
                {
                    var newVariant: Variant!
                    let label = labelArray[index]
                    let issue = issueArray[index]
                    let subLabel = label.split(separator: "_", maxSplits: 1, omittingEmptySubsequences: true)[0]
                    if(label == "variant")
                    {
                        storedLabel = String(describing: issue)
                    }
                    else if(label == "description")
                    {
                        storedIssue = String(describing: issue)
                        newVariant = Variant(numIn: storedLabel, messageIn: storedIssue)
                        variantArray.append(newVariant)
                        count += 1
                    }
                    else if(subLabel == "MD")
                    {
                        newVariant = Variant(numIn: label, messageIn: String(describing: issue))
                        variantArray.append(newVariant)
                        count += 1
                    }
                }
            }
            print(count, " VARIANTS LOADED SUCCESSFULLY")
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        }
        catch{
            print(error)
        }
    }
    func getReturnPos(macName: String) -> String
    {
        var position = ""
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == macName)
            {
                var valueArray = document.arrayRepresentation
                var labelArray = document.keys
                for index in 0 ..< labelArray.count
                {
                    if(labelArray[index] == "pdiPosition")
                    {
                        position = String(describing: valueArray[index])
                    }
                }
            }
        }
        catch{
            print(error)
        }
        return position
    }
    func getActiveStatus(macName: String) -> Int
    {
        var status = 0
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == macName)
            {
                var valueArray = document.arrayRepresentation
                var labelArray = document.keys
                for index in 0 ..< labelArray.count
                {
                    if(labelArray[index] == "active")
                    {
                        status = Int(String(describing: valueArray[index]))!
                    }
                }
            }
        }
        catch{
            print(error)
        }
        return status
    }
    func exists(macName: String) -> Bool
    {
        var exists = false
        var count = 0
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for _ in try inspectedMachines.find("machineId" == macName)
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
    func setInitialFuelConsumption(machine: Machine)
    {
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == machine.name)
            {
                var valueArray = document.arrayRepresentation
                var labelArray = document.keys
                for index in 0 ..< labelArray.count
                {
                    if(labelArray[index] == "fuelBefore")
                    {
                        machine.thisPDI.initialFuelConsumption = Double(String(describing: valueArray[index]))!
                    }
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    func setBatteries(machine: Machine)
    {
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == machine.name)
            {
                var valueArray = document.arrayRepresentation
                var labelArray = document.keys
                for index in 0 ..< labelArray.count
                {
                    if(labelArray[index] == "g001CCA")
                    {
                        machine.thisPDI.G001[0] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "g001Volt")
                    {
                        machine.thisPDI.G001[1] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "g005CCA")
                    {
                        machine.thisPDI.G005[0] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "g005Volt")
                    {
                        machine.thisPDI.G005[1] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "g004CCA")
                    {
                        machine.thisPDI.G004[0] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "g004Volt")
                    {
                        machine.thisPDI.G004[1] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "man1CCA")
                    {
                        machine.thisPDI.MAN1[0] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "man1Volt")
                    {
                        machine.thisPDI.MAN1[1] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "c13CCA")
                    {
                        machine.thisPDI.C13[0] = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "c13Volt")
                    {
                        machine.thisPDI.C13[1] = String(describing: valueArray[index])
                    }
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    func setOMs(machine: Machine)
    {
        do
        {
            let inspectedMachines = db["inspectedMachines"]
            
            for document in try inspectedMachines.find("machineId" == machine.name)
            {
                var valueArray = document.arrayRepresentation
                var labelArray = document.keys
                for index in 0 ..< labelArray.count
                {
                    if(labelArray[index] == "suppOMM")
                    {
                        machine.thisPDI.OMSupp = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "profiCam")
                    {
                        machine.thisPDI.OMProfiCam = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "cemosOMM")
                    {
                        machine.thisPDI.OMCemos = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "mainOMM")
                    {
                        machine.thisPDI.OMMain = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "fittingOMM")
                    {
                        machine.thisPDI.OMFitting = String(describing: valueArray[index])
                    }
                    else if(labelArray[index] == "teraTrackOMM")
                    {
                        machine.thisPDI.OMTeraTrack = String(describing: valueArray[index])
                    }
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    func setVariantResponses(machine: Machine)
    {
    
    }
    func setCheckpointResponses(machine: Machine)
    {
    
    }
    
    /* Function: getString
     *  Purpose: gets the raw data string pulled from remote mongodb
     */
    func getString()
    {
        do
        {
            proccessString = try String(contentsOf: filePath)
            
        }
        catch
        {
            print("COULD NOT ACCESS RAW DATA")
            print(error)
        }
    }
    
}
