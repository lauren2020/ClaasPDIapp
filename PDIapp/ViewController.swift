//
//  ViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/9/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit
//import SQLite

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
    // holds port for moving data back to remote DB
    var exportDat: exportData!
    // holds port for retrieving data from remote db
    var importDat = importData(nameIn: "importDat")
    //********************REMOVE DB DEPENDENCY*****************************
    //file path to machine communication file
    let filePath = Bundle.main.url(forResource: "macComm", withExtension: "txt")!
    //*********************REMOVE LOCAL DEPENDENCY***************************
    //file path to user info stored data
    let filePathUser = Bundle.main.url(forResource: "userInfo", withExtension: "txt")!
    var toggleList = 0;
    let selected = UIImage(named: "selectedButton2") as UIImage?
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var incompPdisButton: UIButton!
    @IBOutlet weak var newPdisButton: UIButton!
    @IBOutlet weak var availibleMachineList: UIPickerView!
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //fills array with machines that have a pdiStatus of 0
        importDat.fillMachines(type: 0)
        machines = importDat.machineArray
        if(machines.count != 0)
        {
            machine = machines[0]
        }
        //Will grab user from internal file
        name = getName()
        
    }
    

    /* Function: getName
     *  Purpose: returns current name value from userInfo table
     *  Variables:
     *       String: userName - holds name value
     *  Returns: userName - current user name
     */
    func getName() -> String
    {
        var userName = "Default"
        do
        {
            userName = try String(contentsOf: filePathUser)
            
        }
        catch
        {
            print("COULD NOT COLLECT USER NAME FROM STORE")
            print(error)
            /******PROMPT FOR USERNAME***********/
        }
        return userName
    }
    
    ////////////////////////////////////////////////////////////
    //****************GROUP PURPOSE FUNCTIONS*******************
    //******Configures picker view with availible machines******
    //
    /* Function: numberOfComponents
     *  Purpose: denote number of desired components
     *  Variables:
     *       UIPickerView: pickerView - references picker view on home screen
     *  Returns: 1 - number of components in picker view
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    /* Function: pickerView
     *  Purpose: denote number of machines(A), denote machine names(B), set current machine equal to selected machine in list(C)
     *  Variables:
     *      Int: numberOfRowsInComponent - number of rows
     *  Returns: machines.count - number of mahines availible for PDI,
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
    
    @IBAction func newPdisPressed(_ sender: Any)
    {
        if(toggleList == 1)
        {
            importDat.fillMachines(type: 0)
            machines = importDat.machineArray
            self.availibleMachineList.reloadAllComponents()
            machine = machines[0]
            subLabel.text = "New PDI's:"
            newPdisButton.setBackgroundImage(selected, for: .normal)
            incompPdisButton.setBackgroundImage(notSelected, for: .normal)
            toggleList = 0
        }
    }
    @IBAction func incompPdisPressed(_ sender: Any)
    {
        if(toggleList == 0)
        {
            importDat.fillMachines(type: 2)
            machines = importDat.machineArray
            self.availibleMachineList.reloadAllComponents()
            if(machines.count != 0)
            {
                machine = machines[0]
            }
            else
            {
                machine = nil
            }
            subLabel.text = "Incomplete PDI's:" //Saved instead of incomplete???
            newPdisButton.setBackgroundImage(notSelected, for: .normal)
            incompPdisButton.setBackgroundImage(selected, for: .normal)
            toggleList = 1
        }
    }
    
    
    
    //
    //*****************END GROUP PURPOSE FUNCTIONS*********************
    ////////////////////////////////////////////////////////////
    
    /* Function: startPressed
     *  Purpose: when start is pressed, configures machine settings and begins PDI
     *  Variables:
     *       machine: Machine object of current machine selection
     */
    @IBAction func startPressed(_ sender: Any)
    {
        //Check to verify machine is selected
        if(machine != nil)
        {
        //Build a new PDI for selected machine
        machine.addPDI(pdiIn: PDI(name: machine.name))
        machine.thisPDI.status = 1
        machine.thisPDI.completedBy = name
        print("NEW PDI ADDED TO MACHINE ", machine.name)
        
        //fill checkpoints in PDI
        importDat.fillCheckpoints(macName: machine.name)
        checkpointsArray = importDat.cpArray
        machine.thisPDI.setQuestionBank(arrayIn: checkpointsArray)
        
        //fill variants in PDI
        importDat.fillVariants(macName: machine.name)
        variantArray = importDat.variantArray
        machine.thisPDI.setVariantBank(arrayIn: variantArray)
        
        //create port for shipping information to db
        exportDat = exportData(machineIn: machine)
        //create new object in collection "inspectedMachines"
        exportDat.createInspected()
        //change status to in progress
        exportDat.macStatus(status: 2)
        //Transfer to next segment of PDI
        self.performSegue(withIdentifier: "startPdiSeg", sender: machine)
        }
        else
        {
            //pop-up "No Machine is Selected"
            print("No Machine is Selected")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "No Machine is Selected"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
    }
    
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Battery scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
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
                vc.exportDat = self.exportDat
                print("exportDat Object Passed to FC")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

