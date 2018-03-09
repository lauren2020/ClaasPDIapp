//
//  VariantsViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class VariantsViewController: UIViewController, UITextFieldDelegate
{
    var toggle = 0
    var xtoggle = 0
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var variantDescription: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    let selected = UIImage(named: "selectedButton2") as UIImage?
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var notOkButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("VariantsView Loaded")
        messageField.delegate = self
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        machine.thisPDI.thisQuestion = 0
        backButton.isHidden = true
        genQuestion()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    /*
     * FUNCTION: okPressed
     * PURPOSE: Sets response to variant to ok
     */
    @IBAction func okPressed(_ sender: Any)
    {
        print("Ok Pressed")
        machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] = 1
        selectOk()
    }
    /* FUNCTION: notOkPressed
    * PURPOSE: Sets response to variant to not ok
    */
    @IBAction func notOkPressed(_ sender: Any)
    {
        print("Not Ok Pressed")
        machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] = 2
        selectNotOk()
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
     * FUNCTION: nextPressed
     * PURPOSE: Moves to segment of the PDI
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        print("Next Pressed")
        exportDat.pushVariants()
        self.performSegue(withIdentifier: "variantsToCheckpoint", sender: machine)
    }
    /*
     * FUNCTION: backVariantPressed
     * PURPOSE: Gos back to previous variant
     */
    @IBAction func backVariantPressed(_ sender: Any)
    {
        print("Back Variant Pressed")
        if(nextButton.isHidden)
        {
            nextButton.isHidden = false
        }
        machine.thisPDI.thisQuestion -= 1
        if(machine.thisPDI.thisQuestion == 0)
        {
            backButton.isHidden = true
        }
        genQuestion()
    }
    /*
     * FUNCTION: nextVariantPressed
     * PURPOSE: Moves to next variant
     */
    @IBAction func nextVariantPressed(_ sender: Any)
    {
        print("Next Variant Pressed")
        if(backButton.isHidden)
        {
            backButton.isHidden = false
        }
        machine.thisPDI.thisQuestion += 1
        if(machine.thisPDI.thisQuestion == machine.thisPDI.variantBank.count - 1)
        {
            nextButton.isHidden = true
        }
        genQuestion()
    }
    /*
     * FUNCTION: genQuestion
     * PURPOSE: Generates a new variant
     */
    func genQuestion()
    {
        print("Generateing Question")
        if(machine.thisPDI.variantBank.count != 0)
        {
            let newVariant = machine.thisPDI.variantBank[machine.thisPDI.thisQuestion]
            number.text = newVariant?.num
            variantDescription.text = newVariant?.message
            if(machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] == 0)
            {
                selectNone()
            }
            else if(machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] == 1)
            {
                selectOk()
            }
            else if(machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] == 2)
            {
                selectNotOk()
            }
        }
        else
        {
            nextButton.isHidden = true
            okButton.isHidden = true
            notOkButton.isHidden = true
            variantDescription.text = "NO VARIANTS"
            number.text = ""
        }
    }
    /*
     * FUNCTION: selectNotOk
     * PURPOSE: sets not ok button image to selected
     */
    func selectNotOk()
    {
        notOkButton.setBackgroundImage(selected, for: .normal)
        okButton.setBackgroundImage(notSelected, for: .normal)
    }
    /*
     * FUNCTION: selectOk
     * PURPOSE: sets ok button image to selected
     */
    func selectOk()
    {
        okButton.setBackgroundImage(selected, for: .normal)
        notOkButton.setBackgroundImage(notSelected, for: .normal)
    }
    /*
     * FUNCTION: selectNone
     * PURPOSE: Sets all button images to unselected
     */
    func selectNone()
    {
        okButton.setBackgroundImage(notSelected, for: .normal)
        notOkButton.setBackgroundImage(notSelected, for: .normal)
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
    
    @IBAction func saveExitPressed(_ sender: Any) {
    }
    
    @IBAction func backPagePressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "VariantsBackToOM", sender: machine)
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
        self.performSegue(withIdentifier: "variantsCancelToMain", sender: machine)
    }
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Checkpoints scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "variantsToCheckpoint" {
            if let vc = segue.destination as? PDIViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.exportDat = self.exportDat
            }
        }
        if segue.identifier == "VariantsBackToOM" {
            if let vc = segue.destination as? OMViewController {
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
