//
//  PDIViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/10/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class PDIViewController: UIViewController, UITextFieldDelegate
{
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    var toggle = 0;
    var xtoggle = 0
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var failureLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var notOkButton: UIButton!
    @IBOutlet weak var naButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    let selected = UIImage(named: "selectedButton2") as UIImage?
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Checkpoints View Loaded")
        messageField.delegate = self
        
        if(machine.thisPDI.checkpointBank.count < 2)
        {
            nextButton.isHidden = true
        }
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
     * FUNCTION: nextPressed
     * PURPOSE: Moves to next checkpoint
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        if(backButton.isHidden)
        {
            backButton.isHidden = false
        }
        machine.thisPDI.thisQuestion += 1
        if(machine.thisPDI.thisQuestion == machine.thisPDI.checkpointBank.count - 1)
        {
            nextButton.isHidden = true
        }
        genQuestion()
    }
    /*
     * FUNCTION: backPressed
     * PURPOSE: Gos back to previous checkpoint
     */
    @IBAction func backPressed(_ sender: Any)
    {
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
     * FUNCTION: genQuestion
     * PURPOSE: Generates a new checkpoint
     */
    func genQuestion()
    {
        //Checks to make sure there are checkpoints
        if(machine.thisPDI.checkpointBank.count != 0)
        {
            let newCheckpoint = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion]
            positionLabel.text = newCheckpoint.position
            failureLabel.text = newCheckpoint.failure
            if(machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] == 0)
            {
                selectNone()
            }
            else if(machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] == 1)
            {
                selectOk()
            }
            else if(machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] == 2)
            {
                selectNotOk()
            }
            else if(machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] == 3)
            {
                selectNa()
            }
        }
        else
        {
            positionLabel.isHidden = true
            notOkButton.isHidden = true
            okButton.isHidden = true
            naButton.isHidden = true
            nextButton.isHidden = true
            failureLabel.text = "NO CHECKPOINTS"
        }
        
    }
    /*
     * FUNCTION: okPressed
     * PURPOSE: Sets response to checkpoint to ok
     */
    @IBAction func okPressed(_ sender: Any)
    {
        machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] = 1
        selectOk()
    }
    /*
     * FUNCTION: notOkPressed
     * PURPOSE: Sets response to checkpoint to not ok
     */
    @IBAction func notOkPressed(_ sender: Any)
    {
        machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] = 2
        selectNotOk()
    }
    /*
     * FUNCTION: naPressed
     * PURPOSE: Sets response to checkpoint to not applicable
     */
    @IBAction func naPressed(_ sender: Any)
    {
        machine.thisPDI.questionResponseBank[machine.thisPDI.thisQuestion] = 3
        selectNa()
    }
    /*
     * FUNCTION: selectNotOk
     * PURPOSE: sets not ok button image to selected
     */
    func selectNotOk()
    {
        notOkButton.setBackgroundImage(selected, for: .normal)
        okButton.setBackgroundImage(notSelected, for: .normal)
        naButton.setBackgroundImage(notSelected, for: .normal)
    }
    /*
     * FUNCTION: selectOk
     * PURPOSE: sets ok button image to selected
     */
    func selectOk()
    {
        okButton.setBackgroundImage(selected, for: .normal)
        notOkButton.setBackgroundImage(notSelected, for: .normal)
        naButton.setBackgroundImage(notSelected, for: .normal)
    }
    /*
     * FUNCTION: selectNa
     * PURPOSE: sets na button image to selected
     */
    func selectNa()
    {
        naButton.setBackgroundImage(selected, for: .normal)
        okButton.setBackgroundImage(notSelected, for: .normal)
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
        naButton.setBackgroundImage(notSelected, for: .normal)
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
     * FUNCTION: completePDI(nextScenePressed)
     * PURPOSE: Moves to the next segment of the PDI
     */
    @IBAction func completePDI(_ sender: Any)
    {
        print("Next Pressed")
        exportDat.pushCheckpoints()
        self.performSegue(withIdentifier: "checkpointsToFinalFC", sender: machine)
    }
    @IBAction func moreInfoPressed(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "moreInfoPopUP") as! PopUpViewController
        popOverVC.passedURL = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].imageURL
        popOverVC.info = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].moreInfo
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
        self.performSegue(withIdentifier: "CheckpointsBackToVariants", sender: machine)
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
        self.performSegue(withIdentifier: "checkpointsCancelToMain", sender: machine)
    }
    /*
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Final Fuel Consumption scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkpointsToFinalFC" {
            if let vc = segue.destination as? FinalFCViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.exportDat = self.exportDat
            }
        }
        if segue.identifier == "CheckpointsBackToVariants" {
            if let vc = segue.destination as? VariantsViewController {
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
