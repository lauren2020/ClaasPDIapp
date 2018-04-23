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
    //port for sending and retrieving data to and from the database
    var Port: port!
    // Indicates whether messages should be sent to the wash bay or issues should be created
    var toggle = 0;
    // Indicates whether close menu options should be shown or hidden
    var xtoggle = 0
    
    var skipToggle = 0
    //indicates whether current list being traversed is checkpoints list or skipped list
    var type = 0;
    //indicates whether type should be changed for next question or not
    var changeType = false
    var thisImage: UIImage!
    
    var thisMessage = ""
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var issueImage: UIImageView!
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
    @IBOutlet weak var currentNumberTag: UILabel!
    @IBOutlet weak var totalNumberTag: UILabel!
    
    // Image for button when it has been selected
    let selected = UIImage(named: "selectedButton2") as UIImage?
    // Image for button when it is un selcted
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Checkpoints View Loaded")
        
        machine.thisPDI.position = "cps"
        
        messageField.delegate = self
        
        //Configure layout
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
        
        //Load resoonses
        if(!Port.checklistArrayExists())
        {
            Port.setCheckpointResponses(machine: machine)
        }
        else
        {
            Port.setCheckpointResponses2(cpId: "fakeid")
        }
        
        //Initializes question counter
        totalNumberTag.text = String(describing: machine.thisPDI.checkpointBank.count)
        
        //Generate first question
        let success = genQuestion()
        if(!success)
        {
            print("ERROR GENERATEING NEXT QUESTION")
        }
    }
    @IBAction func addImage(_ sender: Any)
    {
        /*CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.issueImage.image = image
            self.thisImage = image
            self.issueImage.isHidden = false
        }*/
    }
    /*
     * FUNCTION: touchesBegan
     * PURPOSE: Is called when touch begins
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
     * FUNCTION: textFieldShouldReturn
     * PURPOSE: When text field is done editing, resigns responder
     */
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
        print("Next checkpoint Pressed")
        backButton.isHidden = false
        if(userInSkippedBank())
        {
            let positionInMain = machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position
            if(!unanswered(atPosition: positionInMain!))
            {
                // Remove checkpoint from skipped list and set the question status
                if(checkBoundsOf(bank: 1) && checkpointInSkipped(checkpointPosition: positionInMain!))
                {
                    removeFromSkipped(index: machine.thisPDI.currentSkipped)
                    print("REMOVED SKIPPED checkpoint AT: ", machine.thisPDI.currentSkipped)
                }
                Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[positionInMain!].response, type: 1, id: machine.thisPDI.checkpointBank[positionInMain!].id)
                Port.removeIssue(issueIdentifier: machine.thisPDI.checkpointBank[positionInMain!].id, issueType: 1)
            }
            else
            {
                // Checkpoint is moved to the end of the skipped list
                machine.thisPDI.skippedCheckpointBank.append(machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped])
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            if(notOk(atPosition: positionInMain!))
            {
                addIssueToDB(fromPosition: positionInMain!)
            }
        }
        else
        {
            let positionInMain = machine.thisPDI.thisQuestion
            if(!unanswered(atPosition: machine.thisPDI.thisQuestion))
            {
                // Remove checkpoint from skipped list and set the question status
                if(checkpointInSkipped(checkpointPosition: positionInMain))
                {
                    for location in 0 ..< machine.thisPDI.skippedCheckpointBank.count
                    {
                        if(machine.thisPDI.thisQuestion == machine.thisPDI.skippedCheckpointBank[location].position)
                        {
                            removeFromSkipped(index: location)
                            print("REMOVED SKIPPED checkpoint AT: ", location)
                            break
                        }
                    }
                }
                Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[positionInMain].response, type: 1, id: machine.thisPDI.checkpointBank[positionInMain].id)
                Port.removeIssue(issueIdentifier: machine.thisPDI.checkpointBank[positionInMain].id, issueType: 1)
            }
            if(notOk(atPosition: machine.thisPDI.thisQuestion))
            {
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
                if(machine.thisPDI.skippedCheckpointBank.count == 0)
                {
                    nextButton.isHidden = true
                }
                else
                {
                    print("CHANGEING TYPE")
                    changeType = true
                }
            }
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
        else if(machine.thisPDI.skippedCheckpointBank.count == 1)
        {
            nextButton.isHidden = true
            genSkippedQuestion()
        }
        else
        {
            genSkippedQuestion()
        }
    }
    /*
     * FUNCTION: genSkippedQuestion
     * PURPOSE: Generates a new checkpoint from the skipped list
     */
    func genSkippedQuestion()
    {
        print("***---------------------------------------------------------***")
        print("Generateing Skipped Question")
        if(machine.thisPDI.skippedCheckpointBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position + 1)
            
            let newCheckpoint = machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].checkpoint
            Port.updateSingleResponse(type: 0, id: newCheckpoint!.id, index: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position)
            positionLabel.text = newCheckpoint?.macPosition
            failureLabel.text = newCheckpoint?.failure
            selectNone()
        }
    }
    /*
     * FUNCTION: checkpointInSkipped
     * PURPOSE: Checks if a specified checkpoint (identified by its position) is in the skipped list
     * VARIABLES: Int checkpointPosition = position of checkpoint to be checked for
     * RETURNS: Bool inSkipped -> true if checkpoint is in skipped list, false if not
     */
    func checkpointInSkipped(checkpointPosition: Int) -> Bool
    {
        var inSkipped = false
        if(machine.thisPDI.skippedCheckpointBank.count != 0)
        {
            for index in 0 ..< machine.thisPDI.skippedCheckpointBank.count
            {
                if(machine.thisPDI.skippedCheckpointBank[index].position == checkpointPosition)
                {
                    inSkipped = true
                }
            }
        }
        return inSkipped
    }
    //DEPRECEATED
    /*
     * FUNCTION: addToSkipped
     * PURPOSE: Adds a new checkpoint to the skipped list and tracks the position of that variable in the checkpoint list
     * VARIABLES: checkpoint skippedcheckpoint = checkpoint that was not answered
     *            Int position = position of checkpoint in checkpoint list
     */
    func addToSkipped(skippedCheckpoint: Checkpoint, position: Int)
    {
    }
    /*
     * FUNCTION: removeFromSkipped
     * PURPOSE: Removes a checkpoint from the skipped list
     * VARIABLES: Int index = the position in the skipped list of the checkpoint to be removed
     */
    func removeFromSkipped(index: Int)
    {
        machine.thisPDI.skippedCheckpointBank.remove(at: index)
    }
    /*
     * FUNCTION: skippedPressed
     * PURPOSE: If the "skipped" button is pressed, shows a pop up with a list of all the currently skipped checkpoints
     */
    @IBAction func skippedPressed(_ sender: Any)
    {
        refreshSkipped()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "skippedPopUp") as! SkippedPopUpViewController
        popOverVC.type = 1
        popOverVC.message = "Unanswered Checkpoints"
        popOverVC.bank2 = machine.thisPDI.skippedCheckpointBank
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onJumpPressed = onJumpPressed
    }
    func refreshSkipped()
    {
        Port.refreshList(type: 1)
        machine.thisPDI.skippedCheckpointBank = Port.skippedCheckpointArray
    }
    /*
     * FUNCTION: onJumpPressed
     * PURPOSE: Callback function that is executed upon skipped list pop up window being closed to relay the selcted position to move to
     * PARAMS: jumpPos -> Position to move to in the main bank
     */
    func onJumpPressed(_ jumpPos: Int)
    {
        print("JUMPING TO: ", jumpPos)
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
            type = 0
            machine.thisPDI.currentSkipped = 0
            machine.thisPDI.thisQuestion = jumpPos
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
    }
    /*
     * FUNCTION: incrementCurrentSkipped
     * PURPOSE: Increases the value of currentSkipped by 1
     */
    func incrementCurrentSkipped()
    {
        machine.thisPDI.currentSkipped += 1
        print("Current Skipped ++: ", machine.thisPDI.currentSkipped)
    }
    /*
     * FUNCTION: decrementCurrentSkipped
     * PURPOSE: Decreases the value of currentSkipped by 1
     */
    func decrementCurrentSkipped()
    {
        machine.thisPDI.currentSkipped -= 1
        print("Current Skipped --: ", machine.thisPDI.currentSkipped)
    }
    /*
     * FUNCTION: incrementThisQuestion
     * PURPOSE: Increases the value of thisQuestion by 1
     */
    func incrementThisQuestion()
    {
        machine.thisPDI.thisQuestion += 1
        print("This Question ++: ", machine.thisPDI.thisQuestion)
    }
    /*
     * FUNCTION: decrementThisQuestion
     * PURPOSE: Decreases the value of thisQuestion by 1
     */
    func decrementThisQuestion()
    {
        machine.thisPDI.thisQuestion -= 1
        print("This Question --: ", machine.thisPDI.thisQuestion)
    }
    /*
     * FUNCTION: userInSkippedBank
     * PURPOSE: Checks if the user is in the skipped bank
     * RETURNS: true if user is currently in the skipped bank and false if they are in the main bank
     */
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
    /*
     * FUNCTION: unanswered
     * PURPOSE: Checks if the indicated checkpoint has been answered
     * PARAMS: atPosition -> Position of the checkpoint in the main bank to be checked
     * RETURNS: true if the checkpoint has not been answered and false if it has an answer
     */
    func unanswered(atPosition: Int) -> Bool
    {
        print("Checking if question is unanswered...")
        var unanswered = false
        if(machine.thisPDI.checkpointBank[atPosition].response == 0)
        {
            unanswered = true
            print("QUESTION IS UNANSWERED")
        }
        return unanswered
    }
    /*
     * FUNCTION: notOk
     * PURPOSE: Checks to see if the indicated checkpoint is not ok
     * PARAMS: atPosition -> Position in the main bank of the checkpoint whose response is to be checked
     * RETURNS: true if the response is not ok and false if the response is anything else
     */
    func notOk(atPosition: Int) -> Bool
    {
        print("Checking if response is not ok...")
        var notOk = false
        if(machine.thisPDI.checkpointBank[atPosition].response == 2)
        {
            notOk = true
            print("RESPONSE IS NOT OK")
        }
        return notOk
    }
    /*
     * FUNCTION: switchQuestionBanks
     * PURPOSE: Switches the bank being traversed to which ever one the user is not currently in
     */
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
    /*
     * FUNCTION: setResponse
     * PURPOSE: Sets the response of the checkpoint at the given position to the given response
     * PARAMS: atPosition -> Position of checkpoint to set response of in main bank
     *         to -> Response to be assigned to the given checkpoint
     */
    func setResponse(atPosition: Int, to: Int)
    {
        print("Setting response at: ", atPosition, " to:", to)
        machine.thisPDI.checkpointBank[atPosition].response = to
        Port.setQuestionStatus(status: to, type: 1, id: machine.thisPDI.checkpointBank[atPosition].id)
    }
    /*
     * FUNCTION: response
     * PURPOSE: Returns the response to the checkpoint at the given position in the main bank
     * PARAMS: atPosition -> position of desired response
     * RETURNS: the response to the checkpoint at the given position
     */
    func response(atPosition: Int) -> Int
    {
        print("Getting response...")
        return machine.thisPDI.checkpointBank[atPosition].response
    }
    /*
     * FUNCTION: lastQuestionIn
     * PURPOSE: Checks if the given position is the last quetion in  the indicated bank
     * PARAMS: bank -> indicates whether to check the main bank or the skipped bank
     *          isAt -> Position in bank to check
     * RETURNS: true if the past index is the last question or false if it is not the last question
     */
    func lastQuestionIn(bank: Int, isAt: Int) -> Bool
    {
        print("Checking if question is last...")
        var lastQuestion = false
        //Determines which bank to check
        if(bank == 0)
        {
            // Determines position in main bank
            if(isAt == machine.thisPDI.checkpointBank.count - 1)
            {
                print("LAST QUESTION FOUND AT: ", isAt)
                lastQuestion = true
            }
            else if(isAt > machine.thisPDI.checkpointBank.count - 1)
            {
                print("WARNING: CHECKING FOR LAST QUESTION RESULTED IN OUT OF BOUNDS INDEX")
            }
        }
        else
        {
            // Determines position in skipped bank
            if(isAt == machine.thisPDI.skippedCheckpointBank.count - 1)
            {
                lastQuestion = true
            }
            else if(isAt > machine.thisPDI.skippedCheckpointBank.count - 1)
            {
                print("WARNING: CHECKING FOR LAST QUESTION RESULTED IN OUT OF BOUNDS INDEX")
            }
        }
        return lastQuestion
    }
    /*
     * FUNCTION: checkBoundsOf
     * PURPOSE: Checks to see if the current position is in bounds of the indicated bank
     * PARAMS: bank -> indicates whether the main banks bounds are to be checked or the skipped banks bounds
     * RETURNS: true if the current position is in bounds of its bank and false if it is out of bounds
     */
    func checkBoundsOf(bank: Int) -> Bool
    {
        print("Checking bounds...")
        var inBounds = false
        // Determines which bank to check
        if(bank == 0)
        {
            // Determines position in main bank
            if(machine.thisPDI.thisQuestion >= 0 && machine.thisPDI.thisQuestion < machine.thisPDI.checkpointBank.count)
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
            // Determines position in skipped bank
            if(machine.thisPDI.currentSkipped >= 0 && machine.thisPDI.currentSkipped < machine.thisPDI.skippedCheckpointBank.count)
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
    /*
     * FUNCTION: addIssueToDB
     * PURPOSE: Adds a checkpoint issue to the checkListIssues array in the database and in the local issue bank
     * PARAMS: fromPosition -> Position in the main checkpoint bank of checkpoint to be added to the issues array
     */
    func addIssueToDB(fromPosition: Int)
    {
        machine.thisPDI.questionIssueBank.append(machine.thisPDI.checkpointBank[fromPosition])
        Port.removeIssue(issueIdentifier: machine.thisPDI.checkpointBank[fromPosition].id, issueType: 1)
        Port.addOneCheckpoint(issue: machine.thisPDI.checkpointBank[fromPosition])
    }
    /*
     * FUNCTION: backPressed
     * PURPOSE: Gos back to previous checkpoint
     */
    @IBAction func backPressed(_ sender: Any)
    {
        print("Back checkpoint Pressed")
        
        if(!userInSkippedBank())
        {
            let positionInMain = machine.thisPDI.thisQuestion
            decrementThisQuestion()
            
            if((lastQuestionIn(bank: 0, isAt: machine.thisPDI.thisQuestion) && machine.thisPDI.skippedCheckpointBank.count == 0))
            {
                nextButton.isHidden = true
            }
            else
            {
                nextButton.isHidden = false
            }
            
            if(machine.thisPDI.thisQuestion == 0)
            {
                backButton.isHidden = true
            }
            Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[positionInMain].response, type: 1, id: machine.thisPDI.checkpointBank[positionInMain].id)
            Port.removeIssue(issueIdentifier: machine.thisPDI.checkpointBank[positionInMain].id, issueType: 1)
            if(machine.thisPDI.checkpointBank[positionInMain].response != 0)
            {
                if(checkpointInSkipped(checkpointPosition: positionInMain))
                {
                    for location in 0 ..< machine.thisPDI.skippedCheckpointBank.count
                    {
                        if(machine.thisPDI.thisQuestion == machine.thisPDI.skippedCheckpointBank[location].position)
                        {
                            removeFromSkipped(index: location)
                            print("REMOVED SKIPPED checkpoint AT: ", location)
                            break
                        }
                    }
                }
            }
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
        else
        {
            let positionInMain = machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position
            let thisResponse = machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response
            machine.thisPDI.checkpointBank[positionInMain!].response = thisResponse
            Port.updateSingleResponse(type: 1, id: machine.thisPDI.checkpointBank[machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position)
            if(!unanswered(atPosition: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position))
            {
                Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[positionInMain!].response, type: 1, id: machine.thisPDI.checkpointBank[positionInMain!].id)
                Port.removeIssue(issueIdentifier: machine.thisPDI.checkpointBank[positionInMain!].id, issueType: 1)
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            else
            {
                if(machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response != 0)
                {
                    removeFromSkipped(index: machine.thisPDI.currentSkipped)
                }
            }
            
            if(machine.thisPDI.currentSkipped == 0)
            {
                switchQuestionBanks()
                machine.thisPDI.thisQuestion = machine.thisPDI.checkpointBank.count - 1
                let success = genQuestion()
                if(!success)
                {
                    print("ERROR GENERATEING NEXT QUESTION")
                }
            }
            else
            {
                decrementCurrentSkipped()
                genSkippedQuestion()
            }
            
        }
    }
    /*
     * FUNCTION: genQuestion
     * PURPOSE: Generates a new checkpoint
     */
    func genQuestion() -> Bool
    {
        print("***---------------------------------------------------------***")
        print("Generateing Quesiton...")
        
        
        if(machine.thisPDI.checkpointBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.thisQuestion + 1)
            if(machine.thisPDI.thisQuestion < machine.thisPDI.checkpointBank.count)
            {
                if(machine.thisPDI.thisQuestion >= 0)
                {
                    print("Updateing Response...")
                    Port.updateSingleResponse(type: 1, id: machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].id, index: machine.thisPDI.thisQuestion)
                }
                else
                {
                    backButton.isHidden = true
                    machine.thisPDI.thisQuestion += 1
                    return false
                }
            
                let newCheckpoint = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion]
            
                positionLabel.text = newCheckpoint.macPosition
                failureLabel.text = newCheckpoint.failure
                if(machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response == 0)
                {
                    selectNone()
                }
                else if(machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response == 1)
                {
                    selectOk()
                }
                else if(machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response == 2)
                {
                    selectNotOk()
                }
                else if(machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response == 3)
                {
                    selectNa()
                }
            }
            else if(machine.thisPDI.skippedCheckpointBank.count != 0)
            {
                type = 1
                genSkippedQuestion()
            }
            else
            {
                nextButton.isHidden = true
                machine.thisPDI.thisQuestion -= 1
                return false
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
        return true
    }
    /*
     * FUNCTION: okPressed
     * PURPOSE: Sets response to checkpoint to ok
     */
    @IBAction func okPressed(_ sender: Any)
    {
        print("OK PRESSED")
        if(!userInSkippedBank())
        {
            setResponse(atPosition: machine.thisPDI.thisQuestion, to: 1)
        }
        else
        {
            setResponse(atPosition: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position, to: 1)
            machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response = 1
        }
        selectOk()
    }
    /*
     * FUNCTION: notOkPressed
     * PURPOSE: Sets response to checkpoint to not ok
     */
    @IBAction func notOkPressed(_ sender: Any)
    {
        print("NOT OK PRESSED")
        if(!userInSkippedBank())
        {
            setResponse(atPosition: machine.thisPDI.thisQuestion, to: 2)
        }
        else
        {
            setResponse(atPosition: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position, to: 2)
            machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response = 2
        }
        
        selectNotOk()
    }
    /*
     * FUNCTION: naPressed
     * PURPOSE: Sets response to checkpoint to not applicable
     */
    @IBAction func naPressed(_ sender: Any)
    {
        print("NA PRESSED")
        if(!userInSkippedBank())
        {
            setResponse(atPosition: machine.thisPDI.thisQuestion, to: 3)
        }
        else
        {
            setResponse(atPosition: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position, to: 3)
            machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response = 3
        }
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
            print("Toggle set to: ", toggle)
    }
    /*
     * FUNCTION: showlist
     * PURPOSE: Calls a pop up window that will display the current user added issue in the pdi
     */
    @IBAction func showLIst(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newIssuesPopUp") as! newIssuesPopUpViewController
        popOverVC.Port = Port
        popOverVC.machine = machine
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    //Depreceated
    @IBAction func addIssuePopUp(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddIssuePopUp") as! AddIssuePopUpViewController
        popOverVC.Port = Port
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
            if(thisImage != nil)
            {
                thisMessage = messageField.text!
                //Port.addIssue2(issueIdentifier: "This identifier", issue: messageField.text!, image: thisImage)
                //thisImage = nil
                DispatchQueue.global().async {
                    
                    self.Port.addIssue2(issueIdentifier: "This identifier", issue: self.thisMessage, image: self.thisImage)
                    self.thisImage = nil
                    
                    DispatchQueue.main.async {
                        self.stopActivity()
                    }
                }
            }
            else
            {
                Port.addIssue(issueIdentifier: "This identifier", issue: messageField.text!)
                self.stopActivity()
            }
            issueImage.isHidden = true
            print("ADDED ISSUE")
        }
        else
        {
            //Send Message to wash bay
            Port.sendMessageToWashBay(message: messageField.text!)
            self.stopActivity()
            print("SENT MESSAGE TO WASH BAY")
        }
        messageField.text = ""
    }
    /*
     * FUNCTION: startActivity
     * PURPOSE: Shows the activity indicator and stops recording user touches.
     */
    func startActivity()
    {
        print("Activity Started")
        self.view.alpha = 0.5
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    /*
     * FUNCTION: stopActivity
     * PURPOSE: Hides the activity indicator and resumes responding to user touches
     */
    func stopActivity()
    {
        print("Activity Stopped")
        self.view.alpha = 1
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    /*
     * FUNCTION: showLoadingScreen
     * PURPOSE: Displays the loading view
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
     * FUNCTION: completePDI(nextScenePressed)
     * PURPOSE: Moves to the next segment of the PDI
     */
    @IBAction func completePDI(_ sender: Any)
    {
        print("Next Pressed")
        if(userInSkippedBank())
        {
            //Save Response
            machine.thisPDI.checkpointBank[machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position].response = machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response
            
            Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response, type: 1, id: machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].id)
            
            Port.updateSingleResponse(type: 1, id: machine.thisPDI.checkpointBank[machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].position)
            if(machine.thisPDI.skippedCheckpointBank[machine.thisPDI.currentSkipped].response != 0)
            {
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
        }
        else
        {
            print("Saving Response in main bank...")
            Port.setQuestionStatus(status: machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response, type: 0, id: machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].id)
            if(machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].response != 0 && machine.thisPDI.skippedCheckpointBank.count != 0)
            {
                for index in 0 ..< machine.thisPDI.skippedCheckpointBank.count
                {
                    if(machine.thisPDI.skippedCheckpointBank[index].position == machine.thisPDI.thisQuestion)
                    {
                        removeFromSkipped(index: index)
                    }
                }
            }
        }
        if(!machine.thisPDI.noSkippedVariants && machine.thisPDI.variantBank.count != 0)
        {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "text2ButtonPopUp") as! Text2ButtonPopUpViewController
            popOverVC.messageIn = "Some Variants have been skipped."
            popOverVC.leftTextIn = "Fix"
            popOverVC.rightTextIn = "Continue"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            popOverVC.onPopOptionPressed = onPopOptionPressed
        }
        else if(/*!allCheckpointsAnswered()*/ !Port.verifyCompletion(type: 1) && machine.thisPDI.checkpointBank.count != 0)
        {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "text2ButtonPopUp") as! Text2ButtonPopUpViewController
            popOverVC.messageIn = "Some Checkpoints have been skipped."
            popOverVC.leftTextIn = "Fix"
            popOverVC.rightTextIn = "Continue"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            popOverVC.onPopOptionPressed = onPopOptionPressed
        }
        else
        {
            self.performSegue(withIdentifier: "checkpointsToFinalFC", sender: machine)
        }
    }
    /*
     * FUNCTION: onPopOptionPressed
     * PURPOSE: When the warning popup for unanswered fields is closed, this callback function is excuted to relay to this view controller which option in the pop up was selected.
     * PARAMS: selected -> indicates which button was pressed, 0 == Fix - 1 == Continue
     */
    func onPopOptionPressed(_ selected: Int)
    {
        if(selected == 1)
        {
            self.performSegue(withIdentifier: "checkpointsToFinalFC", sender: machine)
        }
    }
    /*
     * FUNCTION: allCheckpointsAnswered
     * PURPOSE: Checks if all the checkpoints have been answered
     * RETURNS: Bool answered -> true if all variants are answered and false if not
     */
    func allCheckpointsAnswered() -> Bool
    {
        var allAnswered = true
        if(machine.thisPDI.skippedCheckpointBank.count != 0)
        {
            allAnswered = false
        }
        return allAnswered
    }
    /*
     * FUNCTION: moreInfoPressed
     * PURPOSE: Displays a pop up with more information about the current chackpoint
     */
    @IBAction func moreInfoPressed(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "moreInfoPopUP") as! PopUpViewController
        popOverVC.passedURL = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].imageURL
        popOverVC.info = machine.thisPDI.checkpointBank[machine.thisPDI.thisQuestion].moreInfo
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
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
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: saveButton)
        
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
        showLoadingScreen()
        loadingText.text = "Saving PDI..."
        startActivity()
        DispatchQueue.global().async {
            
            //self.saveEntries()
            self.Port.setReturnPos(pos: "cps")
            self.Port.macStatus(status: 2)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "checkpointsCancelToMain", sender: self.machine)
            }
        }
    }
    /*
     * FUNCTION: backPagePressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
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
        showLoadingScreen()
        loadingText.text = "Canceling PDI..."
        startActivity()
        DispatchQueue.global().async {
            
            self.Port.removeInspected()
            self.Port.macStatus(status: 0)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "checkpointsCancelToMain", sender: self.machine)
            }
        }
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
                vc.Port = self.Port
            }
        }
        if segue.identifier == "CheckpointsBackToVariants" {
            if let vc = segue.destination as? VariantsViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}
