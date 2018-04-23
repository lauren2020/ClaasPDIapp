//
//  RedesignedVariantsViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/29/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class RedesignedVariantsViewController: UIViewController, UITextFieldDelegate
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
    //var exportDat: exportData!
    var Port: port!
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
    @IBOutlet weak var currentNumberTag: UILabel!
    @IBOutlet weak var totalNumberTag: UILabel!
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
        
        if(!Port.variantsArrayExists())
        {
            print("Variants array does not exists, loading new variants...")
            Port.setVariantResponses(machine: machine)
        }
        else
        {
            print("Variants array exists, loading existing variants...")
            Port.setVariantsResponses2(cpId: "fackeId")
            /* for index in 0 ..< machine.thisPDI.questionResponseBank.count
             {
             if(machine.thisPDI.questionResponseBank[index] == 0)
             {
             machine.thisPDI.skippedCheckpoints.append(machine.thisPDI.checkpointBank[index])
             }
             }*/
        }
        print("Responses Set")
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        machine.thisPDI.thisQuestion = 0
        backButton.isHidden = true
        
        totalNumberTag.text = String(describing: machine.thisPDI.variantBank.count)
        
        print("VIEW IS LOADED")
        let success = genQuestion()
        if(!success)
        {
            print("ERROR GENERATEING NEXT QUESTION")
        }
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
        
        if(!userInSkippedBank())
        {
            setResponse(atPosition: machine.thisPDI.thisQuestion, to: 1)
        }
        else
        {
            setResponse(atPosition: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position, to: 1)
            machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response = 1
        }
        selectOk()
    }
    /* FUNCTION: notOkPressed
     * PURPOSE: Sets response to variant to not ok
     */
    @IBAction func notOkPressed(_ sender: Any)
    {
        print("Not Ok Pressed")
        if(!userInSkippedBank())
        {
            setResponse(atPosition: machine.thisPDI.thisQuestion, to: 2)
        }
        else
        {
            setResponse(atPosition: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position, to: 2)
            machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response = 2
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
        print("Toggle Set to: ", toggle)
    }
    @IBAction func showList(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newIssuesPopUp") as! newIssuesPopUpViewController
        popOverVC.Port = Port
        popOverVC.machine = machine
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    @IBAction func addIssuePopUp(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddIssuePopUp") as! AddIssuePopUpViewController
        popOverVC.Port = Port
        //popOverVC.machine = machine
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
            Port.addIssue(issueIdentifier: "This identifier", issue: messageField.text!)
            print("ADDED ISSUE")
        }
        else
        {
            //Send Message to wash bay
            Port.sendMessageToWashBay(message: messageField.text!)
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
        machine.thisPDI.variantResponseBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position] = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
            Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
            if(machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response != 0)
            {
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
        if(type == 1 && machine.thisPDI.skippedVariantBank.count != 0 && machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response != 0)
        {
            machine.thisPDI.variantResponseBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position] = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
            removeFromSkipped(index: machine.thisPDI.currentSkipped)
        }
        if(!allVariantsAnswered())
        {
            machine.thisPDI.noSkippedVariants = false
        }
        else
        {
            machine.thisPDI.noSkippedVariants = true
        }
        Port.pushVariants()
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
    @IBAction func moreInfoPressed(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "moreInfoPopUP") as! PopUpViewController
        if(machine.thisPDI.variantBank.count != 0)
        {
            popOverVC.passedURL = machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].imageURL
            popOverVC.info = machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].moreInfo
        }
        else
        {
            popOverVC.info = "No Variants"
        }
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    /*
     * FUNCTION: backVariantPressed
     * PURPOSE: Gos back to previous variant
     */
    @IBAction func backVariantPressed(_ sender: Any)
    {
        print("Back Variant Pressed")
        nextButton.isHidden = false
        if(!userInSkippedBank())
        {
            decrementThisQuestion()
            if(machine.thisPDI.thisQuestion == 0)
            {
                backButton.isHidden = true
            }
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
        else
        {
        machine.thisPDI.variantResponseBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position] = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
            Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
            if(!unanswered(atPosition: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position))
            {
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            
            if(machine.thisPDI.currentSkipped == 0)
            {
                switchQuestionBanks()
                //decrementThisQuestion()
            }
            else
            {
                decrementCurrentSkipped()
            }
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
        backButton.isHidden = false
        if(userInSkippedBank())
        {
            let positionInMain = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position
            if(!unanswered(atPosition: positionInMain!))
            {
                if(checkBoundsOf(bank: 1) && variantInSkipped(variantPosition: positionInMain!))
                {
                    removeFromSkipped(index: machine.thisPDI.currentSkipped)
                    print("REMOVED SKIPPED VARIANT AT: ", machine.thisPDI.currentSkipped)
                }
                Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain!].response, type: 0, id: machine.thisPDI.variantBank[positionInMain!].num)
                Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain!].num, issueType: 0)
            }
            else
            {
            machine.thisPDI.skippedVariantBank.append(machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped])
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            if(notOk(atPosition: positionInMain!))
            {
                //Port.setQuestionStatus(status: 2, type: 0, id: machine.thisPDI.variantBank[positionInMain!].num)
                addIssueToDB(fromPosition: positionInMain!)
            }
        }
        else
        {
            let positionInMain = machine.thisPDI.thisQuestion
            if(!unanswered(atPosition: machine.thisPDI.thisQuestion))
            {
                if(variantInSkipped(variantPosition: positionInMain))
                {
                    for location in 0 ..< machine.thisPDI.skippedVariantBank.count
                    {
                        if(machine.thisPDI.thisQuestion == machine.thisPDI.skippedVariantBank[location].position)
                        {
                            removeFromSkipped(index: location)
                            print("REMOVED SKIPPED VARIANT AT: ", location)
                            break
                        }
                    }
                }
                Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain].response, type: 0, id: machine.thisPDI.variantBank[positionInMain].num)
                Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain].num, issueType: 0)
            }
            if(notOk(atPosition: machine.thisPDI.thisQuestion))
            {
                //Port.setQuestionStatus(status: 2, type: 0, id: machine.thisPDI.variantBank[positionInMain].num)
                addIssueToDB(fromPosition: positionInMain)
            }
        }
        
        if(changeType)
        {
            switchQuestionBanks()
            changeType = false
        }
        
        if(!userInSkippedBank())
        {
            if(!lastQuestionIn(bank: 0, isAt: machine.thisPDI.thisQuestion))
            {
                incrementThisQuestion()
            }
            else
            {
                //REMOVED FROM BEGINNING machine.thisPDI.skippedVariantBank == nil ||
                if(machine.thisPDI.skippedVariantBank.count == 0)
                {
                    nextButton.isHidden = true
                }
                else
                {
                    changeType = true
                }
            }
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
        else if(machine.thisPDI.skippedVariantBank.count == 1)
        {
            nextButton.isHidden = true
            genSkippedQuestion()
        }
    }
    /*
     * FUNCTION: genQuestion
     * PURPOSE: Generates a new variant
     */
    func genQuestion() -> Bool
    {
        print("Generateing Question")
        
        if(machine.thisPDI.variantBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.thisQuestion + 1)
            if(machine.thisPDI.thisQuestion < machine.thisPDI.variantBank.count)
            {
                if(machine.thisPDI.thisQuestion >= 0)
                {
                    Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].id, index: machine.thisPDI.thisQuestion)
                }
                else
                {
                    backButton.isHidden = true
                    return false
                }
                
                let newVariant = machine.thisPDI.variantBank[machine.thisPDI.thisQuestion]
                number.text = newVariant?.num
                variantDescription.text = newVariant?.message
                
                if(response(atPosition: machine.thisPDI.thisQuestion) == 0)
                {
                    selectNone()
                }
                else if(response(atPosition: machine.thisPDI.thisQuestion) == 1)
                {
                    selectOk()
                }
                else if(response(atPosition: machine.thisPDI.thisQuestion) == 2)
                {
                    selectNotOk()
                }
            }
            else if(machine.thisPDI.skippedVariantBank.count != 0)
            {
                type = 1
                genSkippedQuestion()
            }
            else
            {
                nextButton.isHidden = true
                return false
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
        return true
    }
    /*
     * FUNCTION: genSkippedQuestion
     * PURPOSE: Generates a new variant from the skipped list
     */
    func genSkippedQuestion()
    {
        print("Generateing Skipped Question...")
        if(machine.thisPDI.skippedVariantBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position + 1)
            
            let newVariant = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].variant
            Port.updateSingleResponse(type: 0, id: newVariant.id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
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
        print("Checking if variant is in skipped bank...")
        var inSkipped = false
        //CHANGED FROM machine.thisPDI.skippedVariantBank != nil
        if(machine.thisPDI.skippedVariantBank.count != 0)
        {
            for index in 0 ..< machine.thisPDI.skippedVariantBank.count
            {
                if(machine.thisPDI.skippedVariantBank[index].position == variantPosition)
                {
                    inSkipped = true
                    print("VARIANT IS IN SKIPPED BANK")
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
    }
    /*
     * FUNCTION: removeFromSkipped
     * PURPOSE: Removes a variant from the skipped list
     * VARIABLES: Int index = the position in the skipped list of the variant to be removed
     */
    func removeFromSkipped(index: Int)
    {
        machine.thisPDI.skippedVariantBank.remove(at: index)
    }
    /*
     * FUNCTION: skippedPressed
     * PURPOSE: If the "skipped" button is pressed, shows a pop up with a list of all the currently skipped variants
     */
    @IBAction func skippedPressed(_ sender: Any)
    {
        print("Skipped button was pressed...")
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "skippedPopUp") as! SkippedPopUpViewController
        popOverVC.type = 0
        popOverVC.message = "Unanswered Variants"
        popOverVC.bank = machine.thisPDI.skippedVariantBank
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onJumpPressed = onJumpPressed
    }
    func onJumpPressed(_ jumpPos: Int)
    {
        print("Jumping to: ", jumpPos)
        if(jumpPos >= 0)
        {
            if(jumpPos < machine.thisPDI.checkpointBank.count - 1)
            {
                nextButton.isHidden = false
            }
            if(jumpPos > 0)
            {
                backButton.isHidden = false
            }
            machine.thisPDI.currentSkipped = 0
            machine.thisPDI.thisQuestion = jumpPos
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
    }
    func incrementCurrentSkipped()
    {
        machine.thisPDI.currentSkipped += 1
        print("Current Skipped ++: ", machine.thisPDI.currentSkipped)
    }
    func decrementCurrentSkipped()
    {
        machine.thisPDI.currentSkipped -= 1
        print("Current Skipped --: ", machine.thisPDI.currentSkipped)
    }
    func incrementThisQuestion()
    {
        machine.thisPDI.thisQuestion += 1
        print("This Question ++: ", machine.thisPDI.thisQuestion)
    }
    func decrementThisQuestion()
    {
        machine.thisPDI.thisQuestion -= 1
        print("This Question --: ", machine.thisPDI.thisQuestion)
    }
    func userInSkippedBank() -> Bool
    {
        print("Checking if user is in skipped bank...")
        var inSkipped = false
        if(type == 1)
        {
            inSkipped = true
            print("USER IS IN SKIPPED BANK")
        }
        return inSkipped
    }
    func unanswered(atPosition: Int) -> Bool
    {
        print("Checking if question is unanswered...")
        var unanswered = false
        if(machine.thisPDI.variantBank[atPosition].response == 0)
        {
            unanswered = true
            print("QUESTION IS UNANSWERED")
        }
        return unanswered
    }
    func notOk(atPosition: Int) -> Bool
    {
        print("Checking if response is not ok...")
        var notOk = false
        if(machine.thisPDI.variantBank[atPosition].response == 2)
        {
            notOk = true
            print("RESPONSE IS NOT OK")
        }
        return notOk
    }
    func switchQuestionBanks()
    {
        if(type == 0)
        {
            type = 1
            print("USER IS NOW IN SKIPPED BANK")
        }
        else
        {
            type = 0
            print("USER IS NOW IN MAIN BANK")
        }
    }
    func setResponse(atPosition: Int, to: Int)
    {
        print("Setting response at: ", atPosition, " to:", to)
        machine.thisPDI.variantBank[atPosition].response = to
    }
    func response(atPosition: Int) -> Int
    {
        print("Getting response...")
        return machine.thisPDI.variantBank[atPosition].response
    }
    func lastQuestionIn(bank: Int, isAt: Int) -> Bool
    {
        print("Checking if question is last...")
        var lastQuestion = false
        if(bank == 0)
        {
            if(isAt == machine.thisPDI.variantBank.count - 1)
            {
                lastQuestion = true
            }
            else if(isAt > machine.thisPDI.variantBank.count - 1)
            {
                print("WARNING: CHECKING FOR LAST QUESTION RESULTED IN OUT OF BOUNDS INDEX")
            }
        }
        else
        {
            if(isAt == machine.thisPDI.skippedVariantBank.count - 1)
            {
                lastQuestion = true
            }
            else if(isAt > machine.thisPDI.skippedVariantBank.count - 1)
            {
                print("WARNING: CHECKING FOR LAST QUESTION RESULTED IN OUT OF BOUNDS INDEX")
            }
        }
        return lastQuestion
    }
    func checkBoundsOf(bank: Int) -> Bool
    {
        print("Checking bounds...")
        var inBounds = false
        if(bank == 0)
        {
            if(machine.thisPDI.thisQuestion >= 0 && machine.thisPDI.thisQuestion < machine.thisPDI.variantBank.count)
            {
                inBounds = true
                print("THIS QUESTION IS IN BOUNDS OF MAIN BANK")
            }
            else
            {
                print("THIS QUESTION IS OUT OF BOUNDS")
            }
        }
        else
        {
            if(machine.thisPDI.currentSkipped >= 0 && machine.thisPDI.currentSkipped < machine.thisPDI.skippedVariantBank.count)
            {
                inBounds = true
                print("CURRENT SKIPPED IS IN BOUNDS OF SKIPPED BANK")
            }
            else
            {
                print("CURRENT SKIPPED IS OUT OF BOUNDS")
            }
        }
        return inBounds
    }
    func addIssueToDB(fromPosition: Int)
    {
        machine.thisPDI.variantIssueBank.append(machine.thisPDI.variantBank[fromPosition])
        Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[fromPosition].num, issueType: 0)
        Port.addOneVariant(issue: machine.thisPDI.variantBank[fromPosition])
    }
    /*
     * FUNCTION: callWritePopUP
     * PURPOSE: Brings up a pop up box with a text field so user can see what they are typing while keyboard covers message box.
     */
    /*func callWritePopUp()
     {
     let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textEntryPopUp") as! TextEntryPopUpViewController
     popOverVC.message = messageField.text!
     self.addChildViewController(popOverVC)
     self.view.addSubview(popOverVC.view)
     popOverVC.didMove(toParentViewController: self)
     messageField.text = popOverVC.message
     }*/
    /*
     * FUNCTION: textFieldDidBeginEditing
     * PURPOSE: If text box editing is started, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if(textField == messageField)
        {
            moveTextField(textField: messageField, moveDistance: -250, up: true)
        }
    }
    /*
     * FUNCTION: textFieldDidEndEditing
     * PURPOSE: If text box editing is ended, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == messageField)
        {
            moveTextField(textField: messageField, moveDistance: -250, up: false)
        }
    }
    /*
     * FUNCTION: moveTextField
     * PURPOSE: Moves screen up so keyboard doesnt cover textbox at base of screen
     * PARAMS: textField -> textfield to be moved if touched
     *         moveDistance -> distance to move screen
     *         up -> true if screen should go up, false if screen should go down
     */
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool)
    {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
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
        //export
        Port.setReturnPos(pos: "var")
        //Port.setActiveStatus(activeStat: 0)
        Port.macStatus(status: 2)
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
        //export
        Port.removeInspected()
        Port.macStatus(status: 0)
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
                //export
                vc.Port = self.Port
            }
        }
        if segue.identifier == "VariantsBackToOM" {
            if let vc = segue.destination as? OMViewController {
                vc.machine = self.machine
                vc.name = self.name
                //export
                vc.Port = self.Port
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
