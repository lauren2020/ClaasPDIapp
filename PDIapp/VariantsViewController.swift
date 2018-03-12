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
    //indicates whether meassage bar should be configured to "Add an Issue" or "Send Meassage to Wash Bay"
    var toggle = 0
    //indicates whether pressing "X" should open or close drop down menu
    var xtoggle = 0
    var skipToggle = 0
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var exportDat: exportData!
    //0 = VariantBank, 1 = skipped
    //indicates whether current list being traversed is variants list or skipped list
    var type = 0;
    //indicates whether type should be changed for next question or not
    var changeType = false
    
    //Object access identifiers
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
    //Add action fieldOpened() --> callWritePopUp()
    
    /*
     * FUNCTION: okPressed
     * PURPOSE: Sets response to variant to ok
     */
    @IBAction func okPressed(_ sender: Any)
    {
        print("Ok Pressed")
        if(type == 0)
        {
            machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] = 1
        }
        else{
            machine.thisPDI.variantResponseBank[machine.thisPDI.skippedPos[machine.thisPDI.currentSkipped]] = 1
        }
        selectOk()
    }
    /* FUNCTION: notOkPressed
    * PURPOSE: Sets response to variant to not ok
    */
    @IBAction func notOkPressed(_ sender: Any)
    {
        print("Not Ok Pressed")
        if(type == 0)
        {
            machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] = 2
        }
        else{
            machine.thisPDI.variantResponseBank[machine.thisPDI.skippedPos[machine.thisPDI.currentSkipped]] = 1
        }
        
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
        if(type == 1 && machine.thisPDI.skippedResponseBank[machine.thisPDI.currentSkipped] != 0)
        {
            machine.thisPDI.variantResponseBank[machine.thisPDI.skippedPos[machine.thisPDI.currentSkipped]] = machine.thisPDI.skippedResponseBank[machine.thisPDI.currentSkipped]
            removeFromSkipped(index: machine.thisPDI.currentSkipped)
        }
        if(!allVariantsAnswered())
        {
            //Throw PopUp
            /*let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "Some Variants have been skipped."
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)*/
            machine.thisPDI.noSkippedVariants = false
        }
        else
        {
            machine.thisPDI.noSkippedVariants = true
        }
        exportDat.pushVariants()
        self.performSegue(withIdentifier: "variantsToCheckpoint", sender: machine)
    }
    /*
     * FUNCTION: allVariantsAnswered
     * PURPOSE: Checks if all variants have been answered
     * RETURNS: Bool answered -> true if all variants are answered and false if not
     */
    func allVariantsAnswered() -> Bool
    {
        var answered = true
        for index in 0 ..< machine.thisPDI.variantResponseBank.count{
            if(machine.thisPDI.variantResponseBank[index] == 0)
            {
                answered = false
            }
        }
        return answered
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
        if(type == 0)
        {
            machine.thisPDI.thisQuestion -= 1
            if(machine.thisPDI.thisQuestion == 0)
            {
                backButton.isHidden = true
            }
        }
        else
        {
            if(machine.thisPDI.currentSkipped == 0)
            {
                type = 0
                machine.thisPDI.thisQuestion -= 1
            }
            else
            {
                machine.thisPDI.currentSkipped -= 1
            }
        }
        if(type == 0)
        {
            genQuestion()
        }
        else
        {
            genSkippedQuestion()
        }
    }
    /*
     * FUNCTION: nextVariantPressed
     * PURPOSE: Moves to next variant
     */
    @IBAction func nextVariantPressed(_ sender: Any)
    {
        print("Next Variant Pressed")
        //Verify backbutton is visible
        backButton.isHidden = false
        //Checks if question is unanswered and adds the variant to skipped list if it is
        if(type == 0 && machine.thisPDI.variantResponseBank[machine.thisPDI.thisQuestion] == 0)
        {
            print("Skipping: ", machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].num)
            if(!variantInSkipped(variantPosition: machine.thisPDI.thisQuestion))
            {
                addToSkipped(skippedVariant: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion], position: machine.thisPDI.thisQuestion)
            }
        }
        //If current variant is answered, if it is, removes the variant from skipped list
        else if(type == 0 && variantInSkipped(variantPosition: machine.thisPDI.thisQuestion))
        {
            print("skippedPos.count: ", machine.thisPDI.skippedPos.count)
            for location in 0 ..< machine.thisPDI.skippedPos.count
            {
                print("location: ", location)
                if(machine.thisPDI.thisQuestion == machine.thisPDI.skippedPos[location])
                {
                    removeFromSkipped(index: location)
                    break
                }
            }
        }
        //if current variant is skipped and remains unanswerd it is moved to back of list
        else if(type == 1 && machine.thisPDI.skippedResponseBank[machine.thisPDI.currentSkipped] == 0)
        {
            if(!variantInSkipped(variantPosition: machine.thisPDI.thisQuestion))
            {
                addToSkipped(skippedVariant: machine.thisPDI.skipped[machine.thisPDI.currentSkipped], position: machine.thisPDI.skippedPos[machine.thisPDI.currentSkipped])
            }
            removeFromSkipped(index: machine.thisPDI.currentSkipped)
        }
        else if(type == 1 && machine.thisPDI.skippedResponseBank[machine.thisPDI.currentSkipped] != 0)
        {
            print("ENTERS: SKIPPED QUESTION IS ANSWERED")
            print("CurrentSkipped: ", machine.thisPDI.currentSkipped)
            print("Skipped.count: ", machine.thisPDI.skipped.count)
            machine.thisPDI.variantResponseBank[machine.thisPDI.skippedPos[machine.thisPDI.currentSkipped]] = machine.thisPDI.skippedResponseBank[machine.thisPDI.currentSkipped]
            removeFromSkipped(index: machine.thisPDI.currentSkipped)
            //added fo test
            machine.thisPDI.currentSkipped -= 1
            print("Exit CurrentSkipped: ", machine.thisPDI.currentSkipped)
            print("Exit Skipped.count: ", machine.thisPDI.skipped.count)
        }
        //Variant list and skipped list are seperate data structures.
        // eg. VariantList = vl, SkippedList = sl
        //      [vl1][vl2][vl3][vl4][vl5][sl1][sl2]
        //Skipped list is placed at the end of variant list, this statement sets which list is currently being traversed.
        if(changeType)
        {
            if(type == 0)
            {
                type = 1
            }
            else
            {
                type = 0
            }
            changeType = false
        }
        //If the user is currently traversing variant list (not skipped list), the position in the variant list is incremented by 1.
        if(type == 0)
        {
            machine.thisPDI.thisQuestion += 1
        }
        //If the user has reached the end of the variant list, if skipped list contains any objects, the traversal switches to skipped list, otherwise, next is hidden.
        if(machine.thisPDI.thisQuestion >= machine.thisPDI.variantBank.count - 1)
        {
            if(machine.thisPDI.skipped == nil)
            {
                nextButton.isHidden = true
            }
            else if(type == 0)
            {
                changeType = true
            }
            ///CHECK FOR OUT OF INDEX on - 11
            if(type == 1 && machine.thisPDI.currentSkipped == machine.thisPDI.skipped.count - 1)
            {
                //NEXT BUTTON SHOULD NOT BE HIDDEN HERE?
                nextButton.isHidden = true
            }
        }
        if(type == 0)
        {
            genQuestion()
        }
        else if(type == 1)
        {
            genSkippedQuestion()
        }
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
            print("ThisQuestion: ", machine.thisPDI.thisQuestion)
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
     * FUNCTION: genSkippedQuestion
     * PURPOSE: Generates a new variant from the skipped list
     */
    func genSkippedQuestion()
    {
        print("Generateing Question")
        if(machine.thisPDI.skipped.count != 0)
        {
            let newVariant = machine.thisPDI.skipped[machine.thisPDI.currentSkipped]
            number.text = newVariant.num
            variantDescription.text = newVariant.message
            selectNone()
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
    /*
     * FUNCTION: variantInSkipped
     * PURPOSE: Checks if a specified variant (identified by its position) is in the skipped list
     * VARIABLES: Int variantPosition = position of variant to be checked for
     * RETURNS: Bool inSkipped -> true if variant is in skipped list, false if not
     */
    func variantInSkipped(variantPosition: Int) -> Bool
    {
        var inSkipped = false
        if(machine.thisPDI.skippedPos != nil)
        {
            for index in 0 ..< machine.thisPDI.skippedPos.count
            {
                if(machine.thisPDI.skippedPos[index] == variantPosition)
                {
                    inSkipped = true
                }
            }
        }
        return inSkipped
    }
    /*
     * FUNCTION: addToSkipped
     * PURPOSE: Adds a new variant to the skipped list and tracks the position of that variable in the variant list
     * VARIABLES: Variant skippedVariant = variant that was not answered
     *            Int position = position of variant in variant list
     */
    func addToSkipped(skippedVariant: Variant, position: Int)
    {
        if(machine.thisPDI.skipped != nil)
        {
            machine.thisPDI.skipped.append(skippedVariant)
            machine.thisPDI.skippedPos.append(position)
            machine.thisPDI.skippedResponseBank.append(0)
        }
        else
        {
            machine.thisPDI.skipped = [skippedVariant]
            machine.thisPDI.skippedPos = [machine.thisPDI.thisQuestion]
            machine.thisPDI.skippedResponseBank = [0]
        }
    }
    /*
     * FUNCTION: removeFromSkipped
     * PURPOSE: Removes a variant from the skipped list
     * VARIABLES: Int index = the position in the skipped list of the variant to be removed
     */
    func removeFromSkipped(index: Int)
    {
        machine.thisPDI.skipped.remove(at: index)
        machine.thisPDI.skippedPos.remove(at: index)
        machine.thisPDI.skippedResponseBank.remove(at: index)
    }
    /*
     * FUNCTION: skippedPressed
     * PURPOSE: If the "skipped" button is pressed, shows a pop up with a list of all the currently skipped variants
     */
    @IBAction func skippedPressed(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "skippedPopUp") as! SkippedPopUpViewController
        if(machine.thisPDI.skipped != nil)
        {
            print("Skipped Count Doesnt = 0: ", machine.thisPDI.skipped.count)
            var listOfSkipped = ""
            //#: num
            for index in 0 ..< machine.thisPDI.skipped.count
            {
                listOfSkipped.append(String(machine.thisPDI.skippedPos[index]))
                listOfSkipped.append(": ")
                listOfSkipped.append(machine.thisPDI.skipped[index].num)
                listOfSkipped.append("\n")
                print("listOfSkipped: ", listOfSkipped)
            }
            print("Final listOfSkipped: ", listOfSkipped)
            popOverVC.message = listOfSkipped
        }
        else
        {
            popOverVC.message = "No Skipped Variants"
        }
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    /*
     * FUNCTION: callWritePopUP
     * PURPOSE: Brings up a pop up box with a text field so user can see what they are typing while keyboard covers message box.
     */
    func callWritePopUp()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textEntryPopUp") as! TextEntryPopUpViewController
        popOverVC.message = messageField.text!
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        messageField.text = popOverVC.message
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
        exportDat.setReturnPos(pos: "var")
        exportDat.setActiveStatus(activeStat: 0)
        exportDat.macStatus(status: 2)
        self.performSegue(withIdentifier: "variantsCancelToMain", sender: machine)
    }
    /*
     * FUNCTION: backPagePressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
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
