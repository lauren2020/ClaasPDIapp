//
//  OMViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

/*
 * CLASS: OMViewController
 * PURPOSE: Controls the screen that displays and operates OM input
 */
class OMViewController: UIViewController, UITextFieldDelegate
{
    //indicates whether meassage bar should be configured to "Add an Issue" or "Send Meassage to Wash Bay"
    var toggle = 0
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    //indicates whether pressing "X" should open or close drop down menu
    var xtoggle = 0
    
    //Object access identifiers
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var omMainField: UITextField!
    @IBOutlet weak var omSuppField: UITextField!
    @IBOutlet weak var omFittingField: UITextField!
    @IBOutlet weak var omCemosField: UITextField!
    @IBOutlet weak var omTeraTrackField: UITextField!
    @IBOutlet weak var omProfiCamField: UITextField!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("OMView Loaded")
        omMainField.delegate = self
        omSuppField.delegate = self
        omFittingField.delegate = self
        omCemosField.delegate = self
        omTeraTrackField.delegate = self
        omProfiCamField.delegate = self
        messageField.delegate = self
        
        omMainField.text = machine.thisPDI.OMMain
        omSuppField.text = machine.thisPDI.OMSupp
        omFittingField.text = machine.thisPDI.OMFitting
        omCemosField.text = machine.thisPDI.OMCemos
        omTeraTrackField.text = machine.thisPDI.OMTeraTrack
        omProfiCamField.text = machine.thisPDI.OMProfiCam
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    /*
     * FUNCTION: nextPressed
     * PURPOSE: Moves to the next segment of the PDI
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        saveEntries()
        print("Next Pressed")
        self.performSegue(withIdentifier: "omToVariants", sender: machine)
    }
    /*
     * FUNCTION: saveEntries
     * PURPOSE: Saves current battery entries in the machines pdi object
     */
    func saveEntries()
    {
        machine.thisPDI.OMMain = omMainField.text!
        machine.thisPDI.OMSupp = omSuppField.text!
        machine.thisPDI.OMFitting = omFittingField.text!
        machine.thisPDI.OMCemos = omCemosField.text!
        machine.thisPDI.OMTeraTrack = omTeraTrackField.text!
        machine.thisPDI.OMProfiCam = omProfiCamField.text!
        exportDat.pushOM()
    }
    /*
     * FUNCTION: togglePressed
     * PURPOSE: Changes the message configuration between "Add Issue" and "Send message to wash bay"
     */
    @IBAction func togglePressed(_ sender: Any)
    {
        print("Toggle Pressed")
        if(toggle == 0)
        {
            messageTitle.text = "Message to Wash Bay"
            toggleButton.setTitle("Add Issue", for: .normal)
            toggle = 1
        }
        else
        {
            messageTitle.text = "Add Issue"
            toggleButton.setTitle("Wash Bay", for: .normal)
            toggle = 0
        }
    }
    /*
     * FUNCTION: submitPressed
     * PURPOSE: Submits issue or message to appropriate recipient
     */
    @IBAction func submitPressed(_ sender: Any)
    {
        print("Submit Pressed")
        if(toggle == 0)
        {
            //Add issue
            exportDat.addIssue(issue: messageField.text!)
            print("ADDED ISSUE")
        }
        else
        {
            //Send Message to wash bay
            exportDat.sendMessageToWashBay(message: messageField.text!)
            print("SENT MESSAGE TO WASH BAY")
        }
        messageField.text = ""
    }
    /*
     * FUNCTION: xPressed
     * PURPOSE: When "X" button is pressed, displays a drop down menu with the options to "Cancel" or "Save & Exit"
     */
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
    /*
     * FUNCTION: saveExitPressed
     * PURPOSE: If the "Save & Exit" button is pressed, inspectedMachines object stays in database and pdiStatus remains set to "2", user is redirected to home screen
     */
    @IBAction func saveExitPressed(_ sender: Any)
    {
        saveEntries()
        exportDat.setReturnPos(pos: "omm")
        exportDat.setActiveStatus(activeStat: 0)
        exportDat.macStatus(status: 2)
        self.performSegue(withIdentifier: "omCancelToMain", sender: machine)
    }
    
    /*
     * FUNCTION: backPagePressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
    @IBAction func backpagePressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "OMBackToBattery", sender: machine)
    }
    
    /*
     * FUNCTION: cancelPressed
     * PURPOSE: Cancels the current PDI and returns to menu
     */
    @IBAction func omCancelToMain(_ sender: Any)
    {
        print("Cancel Pressed")
        exportDat.removeInspected()
        exportDat.macStatus(status: 0)
        self.performSegue(withIdentifier: "omCancelToMain", sender: machine)
    }
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Variants scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "omToVariants" {
            if let vc = segue.destination as? VariantsViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.exportDat = self.exportDat
            }
        }
        if segue.identifier == "OMBackToBattery" {
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
