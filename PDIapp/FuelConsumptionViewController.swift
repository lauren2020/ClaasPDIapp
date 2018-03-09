//
//  FuelConsumptionViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/10/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class FuelConsumptionViewController: UIViewController, UITextFieldDelegate
{
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    var xtoggle = 0
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fuelConsumptionBox: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet var tapScreen: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fuelConsumptionBox.delegate = self
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        //name is passed from previous segment
        nameLabel.text = name
        //exportDat = exportData(machineIn: machine)
        if(machine.thisPDI.initialFuelConsumption != nil)
        {
            fuelConsumptionBox.text = String(format:"%f", machine.thisPDI.initialFuelConsumption)
        }
        
        
       /* tapScreen = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tapScreen.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapScreen)*/
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        textField.resignFirstResponder()
        return true
    }
    /*func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }*/
  
    /*
     * FUNCTION: nextPressed *
     * Purpose: The purpose of this function is to updatate info in this machines PDI and move to the next screen *
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        //When next is pressed, this saves the begining fuel consumption
        let isFilled = fuelConsumptionBox.hasText
        //let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: fuelConsumptionBox.text!))
        var isDouble = false
        if let lat = fuelConsumptionBox.text,
            let _ = Double(lat) {
            isDouble = true
        }
        else
        {
            isDouble = false
        }
        if (isDouble && isFilled)
        {
            machine.thisPDI.setInitialFuelConsumption(fuelConsumptionIn: Double(fuelConsumptionBox.text!)!)
            exportDat.pushInitialFuelConsumption()
            self.performSegue(withIdentifier: "FCtoBattery", sender: machine)
        }
        else
        {
            //if fuel consumption entry is empty or not valid, message appears in box
            fuelConsumptionBox.text = ""
            fuelConsumptionBox.placeholder = "Enter a Number"
        }
    }
    
    @IBAction func xPressed(_ sender: Any)
    {
        if(xtoggle == 0)
        {
            cancelButton.isHidden = false
            saveButton.isHidden = false
            xtoggle = 1
        }
        else
        {
            cancelButton.isHidden = true
            saveButton.isHidden = true
            xtoggle = 0
        }
    }
    
    @IBAction func saveExitPressed(_ sender: Any)
    {
        exportDat.setReturnPos(pos: "ifc")
        exportDat.setActiveStatus(activeStat: 0)
        self.performSegue(withIdentifier: "fcCancelToMain", sender: machine)
    }
    
    
    /*
     * FUNCITON: cancelPressed
     * PURPOSE: Cancels the current PDI
    */
    @IBAction func cancelPressed(_ sender: Any)
    {
        exportDat.removeInspected()
        exportDat.macStatus(status: 0)
        self.performSegue(withIdentifier: "fcCancelToMain", sender: machine)
    }
    
    /*
     * FUNCTION: prepare
     * PURPOSE: This function sends current machine and individuals name onto Battery scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FCtoBattery" {
            if let vc = segue.destination as? batteryViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.exportDat = self.exportDat
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
