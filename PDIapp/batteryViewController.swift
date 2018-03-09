//
//  batteryViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class batteryViewController: UIViewController, UITextFieldDelegate
{
    //BATTERYS DEPEND ON CONFIGURATION OF MACHINE TYPE
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    var xtoggle = 0
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var C130: UITextField!
    @IBOutlet weak var C131: UITextField!
    @IBOutlet weak var G0011: UITextField!
    @IBOutlet weak var G0010: UITextField!
    @IBOutlet weak var G0050: UITextField!
    @IBOutlet weak var G0051: UITextField!
    @IBOutlet weak var G0040: UITextField!
    @IBOutlet weak var MAN10: UITextField!
    @IBOutlet weak var G0041: UITextField!
    @IBOutlet weak var MAN11: UITextField!
    @IBOutlet weak var MAN20: UITextField!
    @IBOutlet weak var MAN21: UITextField!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Battery View Loaded")
        C130.delegate = self
        C131.delegate = self
        G0011.delegate = self
        G0010.delegate = self
        G0051.delegate = self
        G0050.delegate = self
        G0041.delegate = self
        G0040.delegate = self
        MAN20.delegate = self
        MAN21.delegate = self



        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        if(machine.po2Config >= 0700 && machine.po2Config <= 0799)
        {
            mercedesConfig()
        }
        if(machine.po2Config >= 0600 && machine.po2Config <= 0699)
        {
            c13Config()
        }
        if(machine.po2Config >= 0900 && machine.po2Config <= 0999)
        {
            manConfig()
        }
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
     * PURPOSE: This function updates the battery values in the PDI based on the content of the fields and proceeds to next scene
    */
    @IBAction func nextPressed(_ sender: Any)
    {
        print("Next Pressed")
        machine.thisPDI.C13[0] = C130.text!
        machine.thisPDI.C13[1] = C131.text!
        machine.thisPDI.G001[0] = G0010.text!
        machine.thisPDI.G001[1] = G0011.text!
        machine.thisPDI.G005[0] = G0050.text!
        machine.thisPDI.G005[1] = G0051.text!
        machine.thisPDI.G004[0] = G0040.text!
        machine.thisPDI.G004[1] = G0041.text!
        machine.thisPDI.MAN1[0] = MAN10.text!
        machine.thisPDI.MAN1[1] = MAN11.text!
        machine.thisPDI.MAN2[0] = MAN20.text!
        machine.thisPDI.MAN2[1] = MAN21.text!
        exportDat.pushBattery()
        self.performSegue(withIdentifier: "batteryToOm", sender: machine)
    }
    func c13Config()
    {
        C130.isHidden = false
        C130.text = machine.thisPDI.C13[0]
        C131.isHidden = false
        C131.text = machine.thisPDI.C13[1]
        G0010.isHidden = true
        G0011.isHidden = true
        G0050.isHidden = true
        G0051.isHidden = true
        G0040.isHidden = true
        G0041.isHidden = true
        MAN10.isHidden = true
        MAN11.isHidden = true
        MAN20.isHidden = true
        MAN21.isHidden = true
    }
    func mercedesConfig()
    {
        C130.isHidden = true
        C131.isHidden = true
        G0010.isHidden = false
        G0010.text = machine.thisPDI.G001[0]
        G0011.isHidden = false
        G0011.text = machine.thisPDI.G001[1]
        G0050.isHidden = false
        G0050.text = machine.thisPDI.G005[0]
        G0051.isHidden = false
        G0051.text = machine.thisPDI.G005[1]
        G0040.isHidden = false
        G0040.text = machine.thisPDI.G004[0]
        G0041.isHidden = false
        G0041.text = machine.thisPDI.G004[1]
        MAN10.isHidden = true
        MAN11.isHidden = true
        MAN20.isHidden = true
        MAN21.isHidden = true
    }
    func manConfig()
    {
        C130.isHidden = true
        C131.isHidden = true
        G0010.isHidden = true
        G0011.isHidden = true
        G0050.isHidden = true
        G0051.isHidden = true
        G0040.isHidden = true
        G0041.isHidden = true
        MAN10.isHidden = false
        MAN10.text = machine.thisPDI.MAN1[0]
        MAN11.isHidden = false
        MAN11.text = machine.thisPDI.MAN1[1]
        MAN20.isHidden = false
        MAN20.text = machine.thisPDI.MAN2[0]
        MAN21.isHidden = false
        MAN21.text = machine.thisPDI.MAN2[1]
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
        exportDat.setReturnPos(pos: "bat")
        exportDat.setActiveStatus(activeStat: 0)
        self.performSegue(withIdentifier: "batteryCancelToMain", sender: machine)
    }
    @IBAction func backPagePressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "batteryBackToFC", sender: machine)
    }
    
    /*
     * FUNCTION: cancelPressed
     * PURPOSE: Cancels the current PDI and returns to menu
     */
    @IBAction func cancelPressed(_ sender: Any)
    {
        print("Cancel Pressed")
        exportDat.removeInspected()
        exportDat.macStatus(status: 0)
        self.performSegue(withIdentifier: "batteryCancelToMain", sender: machine)
    }
    
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto OM scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "batteryToOm" {
            if let vc = segue.destination as? OMViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.exportDat = self.exportDat
            }
        }
        if segue.identifier == "batteryBackToFC" {
            if let vc = segue.destination as? FuelConsumptionViewController {
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
