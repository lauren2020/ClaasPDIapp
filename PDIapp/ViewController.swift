//
//  ViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/9/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    //array of currently availible machines
    var machines = [Machine]()
    // selected machine to perform PDI on
    var machine: Machine!
    // name of user performing PDI
    var name: String!
    // Array of checkpoints for the PDI
    var checkpointsArray = [Checkpoint]()
    // Array of variants for the PDI
    var variantArray = [Variant]()
    // Array of checkpoints in sorted order based on position on machine
    var sortedArray = [Checkpoint]()
    // Array of skipped variants in order of unskipped variants
    var sortedSkipArray = [SkippedCheckpoint]()
    //holds port for retrieving and assigning data to and from database
    var Port = port()
    var notInitial = true
    // URL to location of users stored name
    let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    //file path to user info stored data (Stores the name of the user)
    let filePathUser = Bundle.main.url(forResource: "userInfo", withExtension: "txt")!
    // Identifys whether machines with pdiStatus = 0 should be shown or with pdiStatus = 2
    var toggleList = 0;
    // Shows button as highlighted in blue
    let selected = UIImage(named: "selectedButton2") as UIImage?
    // Shows Button as unhighlighted in plain gray
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    // UILabel that displays whether the list is new pdis or incomplete pdis
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet weak var subLabel: UILabel!
    // Button to switch to list of incomplete pdis
    @IBOutlet weak var incompPdisButton: UIButton!
    // Button to switch to list of new pdis
    @IBOutlet weak var newPdisButton: UIButton!
    // Picker list that holds machines to be selected from
    @IBOutlet weak var availibleMachineList: UIPickerView!
    // View to display while machine content is loading
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var changeUserButton: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var segId = "startPdiSeg"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicator = thisActivity
        
        //fills array with machines that have a pdiStatus of 0
        if(notInitial)
        {
            Port.fillMachines(type: 0)
        }
        machines = Port.machineArray
        if(machines.count != 0)
        {
            machine = machines[0]
        }
        
        //Gets user name
        name = getName()
        if(Port.connectionSuccesful == nil)
        {
            print("ERROR IN CHECKING CONNECTION STATUS")
        }
        else if(!Port.connectionSuccesful)
        {
            couldNotConnect()
        }
        //activityIndicator = thisActivity
    }
    
    func startActivity()
    {
        print("Activity Started")
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    func stopActivity()
    {
        print("Activity Stoped")
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    

    /* FUNCTION: getName
     *  PPURPOSE: returns current name value from stored file or prompts user to enter a name if none exists
     *  PARAMS:
     *       String: userName - holds name value
     *  RETURNS: userName - current user name
     */
    func getName() -> String
    {
        var userName = "Default"
        do
        {
            let fileURL = docDirURL.appendingPathComponent("storedUserName").appendingPathExtension("txt")
            userName = try String(contentsOf: fileURL)
            if(userName == "" || userName == "\n")
            {
                print("USER NAME IS EMPTY")
                getNamePopUp()
            }
            
        }
        catch
        {
            print("USER NAME COULD NOT BE FOUND")
            getNamePopUp()
            print("COULD NOT COLLECT USER NAME FROM STORE")
            print(error)
            /******PROMPT FOR USERNAME***********/
        }
        return userName
    }
    /*
     * FUNCTION: getNamePopUp
     * PURPOSE: Displays a popup that gets the users name
     */
    func getNamePopUp()
    {
        print("GET NAME POP UP CALLED")
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textEntryPopUp") as! TextEntryPopUpViewController
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onNameSet = onNameSet
    }
    /*
     * FUNCTION: onNameSet
     * PURPOSE: When the user submits there entered name in the pop up window, this function is called to write the given name to an internal file
     * PARAMS: nameIn - the name entered by the user
     */
    func onNameSet(_ nameIn: String)
    {
        //write name to file
        do
        {
            print("NAME: ",nameIn)
            name = nameIn
            let fileURL = docDirURL.appendingPathComponent("storedUserName").appendingPathExtension("txt")
            try name.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            let readText = try String(contentsOf: fileURL)
            print("Read Text: ", readText)
            print("NAME SAVED SUCCESFULLY")
        }
        catch
        {
            print("NAME COULD NOT SAVE")
            print(error)
        }
        name = nameIn
    }
    /*
     * FUNCTION: changeUser
     * PURPOSE: Changes the user name that is stored
     * PARAMS: nameIn - the name entered by the user
     */
    @IBAction func changeUser(_ sender: Any)
    {
        getNamePopUp()
    }
    ////////////////////////////////////////////////////////////
    //****************GROUP PURPOSE FUNCTIONS*******************
    //******Configures picker view with availible machines******
    //
    /* FUNCTION: numberOfComponents
     *  PURPOSE: denote number of desired components
     *  PARAMS:
     *       UIPickerView: pickerView - references picker view on home screen
     *  RETURNS: 1 - number of components in picker view
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    /* FUNCTION: pickerView
     *  PURPOSE: denote number of machines(A), denote machine names(B), set current machine equal to selected machine in list(C)
     *  PARAMS:
     *      Int: numberOfRowsInComponent - number of rows
     *  RETURNS: machines.count - number of mahines availible for PDI,
     *      machines[row].name - machine name for row
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return machines.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return machines[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(machines.count != 0)
        {
            machine = machines[row]
        }
    }
    //
    //*****************END GROUP PURPOSE FUNCTIONS*********************
    ////////////////////////////////////////////////////////////
    
    /*
     * FUNCTION: newPdisPressed
     * PURPOSE: Resets the picker view to display machines with new pdis (machines with pdiStatus = 0)
     */
    @IBAction func newPdisPressed(_ sender: Any)
    {
        if(toggleList == 1)
        {
            Port.fillMachines(type: 0)
            machines = Port.machineArray
            self.availibleMachineList.reloadAllComponents()
            if(machines.count != 0)
            {
                machine = machines[0]
            }
            else
            {
                machine = nil
            }
            subLabel.text = "New PDI's:"
            newPdisButton.setBackgroundImage(selected, for: .normal)
            incompPdisButton.setBackgroundImage(notSelected, for: .normal)
            toggleList = 0
        }
    }
    /*
     * FUNCTION: incompPdisPressed
     * PURPOSE: Resets the picker view to display machines with incomplete pdis (machines with pdiStatus = 2)
     */
    @IBAction func incompPdisPressed(_ sender: Any)
    {
        if(toggleList == 0)
        {
            Port.fillMachines(type: 2)
            machines = Port.machineArray
            self.availibleMachineList.reloadAllComponents()
            if(machines.count != 0)
            {
                machine = machines[0]
            }
            else
            {
                machine = nil
            }
            subLabel.text = "In Progress PDI's:"
            newPdisButton.setBackgroundImage(notSelected, for: .normal)
            incompPdisButton.setBackgroundImage(selected, for: .normal)
            toggleList = 1
        }
    }
    
    /* FUNCTION: startPressed
     * PURPOSE: when start is pressed, configures machine settings and begins PDI
     */
    @IBAction func startPressed1(_ sender: Any)
    {
        //UNCOMMENT TO ADD LOADING SCREEN FEATURE
        showLoadingScreen()
        //Check to verify machine is selected
        if(machine != nil)
        {
            Port.setMachine(machineIn: machine)
            //Build a new PDI for selected machine
            machine.addPDI(pdiIn: PDI(name: machine.name))
            machine.thisPDI.status = 1
            machine.thisPDI.completedBy = name
            print("NEW PDI ADDED TO MACHINE ", machine.name)
        
            //create port for shipping information to db
            Port.setMachine(machineIn: machine)
            
            //if the current machine pdiStatues == 2
            if(Port.inspectedExists(macName: machine.name))
            {
                print("Starting from saved...")
                
                //fill checkpoints in PDI
                Port.fillCheckpoints(macName: machine.name, reload: true)
                checkpointsArray = Port.cpArray
                machine.thisPDI.setQuestionBank(arrayIn: checkpointsArray)
                sortCheckpoints()
                
                //fill oms in PDI
                Port.fillOM(reload: true)
                for index in 0 ..< Port.omsArray.count
                {
                    machine.thisPDI.omBank.append(Port.omsArray[index])
                }
                for om in machine.thisPDI.omBank
                {
                    print("OMS LOADED:", om.dbIdentifier)
                }
                
                
                //fill variants in PDI
                Port.fillVariants(reload: true)
                variantArray = Port.variantArray
                machine.thisPDI.setVariantBank(arrayIn: variantArray)
                
                //***********************************THIS IS OUDATED
                //create new object in collection "inspectedMachines"
                //Port.createInspected()
                
                //change status to in progress
                Port.macStatus(status: 2)
                let position = Port.getReturnPos()
                //************************************THESE ARE NOT NEEDED DUE TO REFRESH ON EACH PAGE LOAD, REMOVE?
                //load ifc
                //load battery
                //load om
                //load variant responsebank
                //load checkpoint response bank
                if(position == "ifc")
                {
                    Port.setInitialFuelConsumption(machine: machine)
                    self.performSegue(withIdentifier: "startPdiSeg", sender: machine)
                }
                else if(position == "bat")
                {
                    Port.setInitialFuelConsumption(machine: machine)
                    Port.setBatteries(machine: machine)
                    self.performSegue(withIdentifier: "startToBAT", sender: machine)
                }
                else if(position == "omm")
                {
                    Port.setInitialFuelConsumption(machine: machine)
                    Port.setBatteries(machine: machine)
                    Port.setOMs(machine: machine, pdiCreated: false)
                    self.performSegue(withIdentifier: "startToOMM", sender: machine)
                }
                else if(position == "var")
                {
                    Port.setInitialFuelConsumption(machine: machine)
                    Port.setBatteries(machine: machine)
                    Port.setOMs(machine: machine, pdiCreated: false)
                    self.performSegue(withIdentifier: "startToVAR", sender: machine)
                }
                else if(position == "cps")
                {
                    Port.setInitialFuelConsumption(machine: machine)
                    Port.setBatteries(machine: machine)
                    Port.setOMs(machine: machine, pdiCreated: false)
                    self.performSegue(withIdentifier: "startToCPS", sender: machine)
                }
                else
                {
                    self.performSegue(withIdentifier: "startPdiSeg", sender: machine)
                }
            }
            else
            {
                print("Starting NEW PDI...")
                Port.addSis()
                print("Added SI...")
                
                //fill checkpoints in PDI
                Port.fillCheckpoints(macName: machine.name, reload: false)
                checkpointsArray = Port.cpArray
                machine.thisPDI.setQuestionBank(arrayIn: checkpointsArray)
                print("Added Checkpoints...")
                
                //fill oms in PDI
                Port.fillOM(reload: false)
                for index in 0 ..< Port.omsArray.count
                {
                    machine.thisPDI.omBank.append(Port.omsArray[index])
                }
                for om in machine.thisPDI.omBank
                {
                    print("OMS LOADED:", om.dbIdentifier)
                }
                
                //fill variants in PDI
                Port.fillVariants(reload: false)
                variantArray = Port.variantArray
                machine.thisPDI.setVariantBank(arrayIn: variantArray)
                machine.thisPDI.skippedVariantBank = Port.skippedVariantArray
                
                sortCheckpoints()
                
                print("Added Variants...")
                Port.macStatus(status: 2)
                self.performSegue(withIdentifier: "startPdiSeg", sender: machine)
            }
        }
        else
        {
            //Show pop-up "No Machine is Selected"
            print("No Machine is Selected")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "No Machine is Selected"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
    }
    @IBAction func startPressed(_ sender: Any)
    {
        //UNCOMMENT TO ADD LOADING SCREEN FEATURE
        showLoadingScreen()
        startActivity()
        //Check to verify machine is selected
        if(machine != nil)
        {
            DispatchQueue.global().async {
                self.Port.setMachine(machineIn: self.machine)
            //Build a new PDI for selected machine
                self.machine.addPDI(pdiIn: PDI(name: self.machine.name))
                self.machine.thisPDI.status = 1
                self.machine.thisPDI.completedBy = self.name
                print("NEW PDI ADDED TO MACHINE ", self.machine.name)
            
            //create port for shipping information to db
                self.Port.setMachine(machineIn: self.machine)
            
            //if the current machine pdiStatues == 2
                if(self.Port.inspectedExists(macName: self.machine.name))
            {
                print("Starting from saved...")
                
                //fill checkpoints in PDI
                self.Port.fillCheckpoints(macName: self.machine.name, reload: true)
                self.checkpointsArray = self.Port.cpArray
                self.machine.thisPDI.setQuestionBank(arrayIn: self.checkpointsArray)
                self.sortCheckpoints()
                
                //fill oms in PDI
                self.Port.fillOM(reload: true)
                for index in 0 ..< self.Port.omsArray.count
                {
                    self.machine.thisPDI.omBank.append(self.Port.omsArray[index])
                }
                for om in self.machine.thisPDI.omBank
                {
                    print("OMS LOADED:", om.dbIdentifier)
                }
                
                self.Port.setPerformer()
                
                
                //fill variants in PDI
                self.Port.fillVariants(reload: true)
                self.variantArray = self.Port.variantArray
                self.machine.thisPDI.setVariantBank(arrayIn: self.variantArray)
                
                //***********************************THIS IS OUDATED
                //create new object in collection "inspectedMachines"
                //self.Port.createInspected()
                
                //change status to in progress
                self.Port.macStatus(status: 2)
                let position = self.Port.getReturnPos()
                //************************************THESE ARE NOT NEEDED DUE TO REFRESH ON EACH PAGE LOAD, REMOVE?
                //load ifc
                //load battery
                //load om
                //load variant responsebank
                //load checkpoint response bank
                if(position == "ifc")
                {
                    self.Port.setInitialFuelConsumption(machine: self.machine)
                    self.segId = "startPdiSeg"
                    //self.performSegue(withIdentifier: "startPdiSeg", sender: self.machine)
                }
                else if(position == "bat")
                {
                    self.Port.setInitialFuelConsumption(machine: self.machine)
                    self.Port.setBatteries(machine: self.machine)
                    self.segId = "startToBAT"
                    //self.performSegue(withIdentifier: "startToBAT", sender: self.machine)
                }
                else if(position == "omm")
                {
                    self.Port.setInitialFuelConsumption(machine: self.machine)
                    self.Port.setBatteries(machine: self.machine)
                    self.Port.setOMs(machine: self.machine, pdiCreated: false)
                    self.segId = "startToOMM"
                    //self.performSegue(withIdentifier: "startToOMM", sender: self.machine)
                }
                else if(position == "var")
                {
                    self.Port.setInitialFuelConsumption(machine: self.machine)
                    self.Port.setBatteries(machine: self.machine)
                    self.Port.setOMs(machine: self.machine, pdiCreated: false)
                    self.segId = "startToVAR"
                    //self.performSegue(withIdentifier: "startToVAR", sender: self.machine)
                }
                else if(position == "cps")
                {
                    self.Port.setInitialFuelConsumption(machine: self.machine)
                    self.Port.setBatteries(machine: self.machine)
                    self.Port.setOMs(machine: self.machine, pdiCreated: false)
                    self.segId = "startToCPS"
                    //self.performSegue(withIdentifier: "startToCPS", sender: self.machine)
                }
                else
                {
                    self.segId = "startPdiSeg"
                    //self.performSegue(withIdentifier: "startPdiSeg", sender: self.machine)
                }
            }
            else
            {
                print("Starting NEW PDI...")
                
                self.Port.addSis()
                print("Added SI...")
                
                //fill checkpoints in PDI
                self.Port.fillCheckpoints(macName: self.machine.name, reload: false)
                self.checkpointsArray = self.Port.cpArray
                self.machine.thisPDI.setQuestionBank(arrayIn: self.checkpointsArray)
                print("Added Checkpoints...")
                
                //fill oms in PDI
                self.Port.fillOM(reload: false)
                for index in 0 ..< self.self.Port.omsArray.count
                {
                    self.machine.thisPDI.omBank.append(self.Port.omsArray[index])
                }
                for om in self.machine.thisPDI.omBank
                {
                    print("OMS LOADED:", om.dbIdentifier)
                }
                
                //fill variants in PDI
                self.Port.fillVariants(reload: false)
                self.variantArray = self.Port.variantArray
                self.machine.thisPDI.setVariantBank(arrayIn: self.variantArray)
                self.machine.thisPDI.skippedVariantBank = self.Port.skippedVariantArray
                
                self.sortCheckpoints()
                self.Port.setPerformer()
                
                print("Added Variants...")
                self.Port.macStatus(status: 2)
                self.segId = "startPdiSeg"
                //self.performSegue(withIdentifier: "startPdiSeg", sender: self.machine)
            }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.segId, sender: self.machine)
                    self.stopActivity()
                }
            }
        }
        else
        {
            //Show pop-up "No Machine is Selected"
            print("No Machine is Selected")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "No Machine is Selected"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
    }
    /*
     * FUNCTION: sortCheckpoints
     * PURPOSE: Sorts the list of checkpoints based on location on the machine
     */
    func sortCheckpoints()
    {
        //Top, Cab Inside/Outside, Front, Right, Back, Left, Over All
        var topArray = [Checkpoint]()
        var cabArray = [Checkpoint]()
        var frontArray = [Checkpoint]()
        var rightArray = [Checkpoint]()
        var backArray = [Checkpoint]()
        var leftArray = [Checkpoint]()
        var overAllArray = [Checkpoint]()
        var position = 0
        
        machine.thisPDI.skippedCheckpointBank.removeAll()
        
        
        for checkpoint in machine.thisPDI.checkpointBank
        {
            if(checkpoint.macPosition == "Top")
            {
                topArray.append(checkpoint)
            }
            else if(checkpoint.macPosition == "Cab Inside/Outside")
            {
                cabArray.append(checkpoint)
            }
            else if(checkpoint.macPosition == "Front")
            {
                frontArray.append(checkpoint)
            }
            else if(checkpoint.macPosition == "Right")
            {
                rightArray.append(checkpoint)
            }
            else if(checkpoint.macPosition == "Back")
            {
                backArray.append(checkpoint)
            }
            else if(checkpoint.macPosition == "Left")
            {
                leftArray.append(checkpoint)
            }
            else
            {
                overAllArray.append(checkpoint)
            }
        }
        for checkpoint in topArray
        {
            checkpoint.position = position
           // print("Top Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in cabArray
        {
            checkpoint.position = position
           // print("cab Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in frontArray
        {
            checkpoint.position = position
           // print("front Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in rightArray
        {
            checkpoint.position = position
           // print("right Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in backArray
        {
            checkpoint.position = position
           // print("back Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in leftArray
        {
            checkpoint.position = position
           // print("left Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        for checkpoint in overAllArray
        {
            checkpoint.position = position
           // print("overall Position: ", position)
            sortedArray.append(checkpoint)
            machine.thisPDI.skippedCheckpointBank.append(SkippedCheckpoint(checkpointIn: checkpoint, positionIn: position))
            position += 1
        }
        
        machine.thisPDI.checkpointBank = sortedArray
    }
    /*
     * FUNCTION: showLoadingScreen
     * PURPOSE: Displays the loading screen while machine settings are configuring
     */
    func showLoadingScreen()
    {
        loadingView.isHidden = false
        loadingView.bounds.size.width = view.bounds.width
        loadingView.bounds.size.height = view.bounds.height
        loadingView.center = view.center
        loadingView.alpha = 1
        //self.view.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        self.view.bringSubview(toFront: loadingView)
        self.view = loadingView
        print("Loading screen succeeded")
    }
    /*
     * FUNCTION: showLoadingScreen
     * PURPOSE: Displays the loading screen while machine settings are configuring
     */
    func closeLoadingScreen()
    {
        loadingView.isHidden = true
        //self.view.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        self.view.bringSubview(toFront: view)
        self.view = view
        print("Closing screen succeeded")
    }
    /*
     * FUNCTION: couldNotConnect
     * PURPOSE: Displays a pop up when connection to the database fails and prompts the user to check there network settings
     */
    func couldNotConnect()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = "Could not connect, make sure you are using 'cwgast'"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    @IBAction func returnToHome(_ sender: Any)
    {
        self.performSegue(withIdentifier: "pdiToHomeScreen", sender: self.machine)
    }
    
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Battery scene
     * PARAMS: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startPdiSeg"
        {
            if let vc = segue.destination as? FuelConsumptionViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to FC")
            }
        }
        if segue.identifier == "startToBAT"
        {
            if let vc = segue.destination as? batteryViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to Battery")
            }
        }
        if segue.identifier == "startToOMM"
        {
            if let vc = segue.destination as? OMViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to OM")
            }
        }
        if segue.identifier == "startToVAR"
        {
            if let vc = segue.destination as? VariantsViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to Variants")
            }
        }
        if segue.identifier == "startToCPS"
        {
            if let vc = segue.destination as? PDIViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to Checkpoints")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        checkpointsArray.removeAll(keepingCapacity: false)
        variantArray.removeAll(keepingCapacity: false)
        sortedArray.removeAll(keepingCapacity: false)
    }


}

