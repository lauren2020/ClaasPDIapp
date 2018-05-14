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
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending and recieving data data to and from the database
    var Port: port!
    //0 = VariantBank, 1 = skipped
    //indicates whether current list being traversed is variants list or skipped list
    var type = 0;
    //indicates whether type should be changed for next question or not
    var changeType = false
    // Holds the image to be appened to the new issue when submitted
    var thisImage: UIImage!
    // Holds the message to be sent when new issue is created
    var thisMessage = ""
    // Icon that indicates background activity to user
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    // Image for button when it is selected
    let selected = UIImage(named: "selectedButton2") as UIImage?
    // Image for button when it is unselected
    let notSelected = UIImage(named: "EmptyButton") as UIImage?
    
    //Object access identifiers
    @IBOutlet weak var checkConnectionButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var issueImage: UIImageView!
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var variantDescription: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var currentNumberTag: UILabel!
    @IBOutlet weak var totalNumberTag: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var notOkButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("VariantsView Loaded")
        
        machine.thisPDI.position = "var"
        
        messageField.delegate = self
        
        // Loads variants from database
        if(!Port.variantsArrayExists())
        {
            print("Variants array does not exists, loading new variants...")
            Port.setVariantResponses(machine: machine)
        }
        else
        {
            print("Variants array exists, loading existing variants...")
            Port.setVariantsResponses2(cpId: "fackeId")
        }
        print("Responses Set")
        
        // Sets up screen visual elements
        cancelButton.isHidden = true
        saveButton.isHidden = true
        refreshButton.isHidden = true
        checkConnectionButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        machine.thisPDI.thisQuestion = 0
        backButton.isHidden = true
        
        totalNumberTag.text = String(describing: machine.thisPDI.variantBank.count)
        
        print("VIEW IS LOADED")
        // Generates first question
        let success = genQuestion()
        if(!success)
        {
            print("ERROR GENERATEING NEXT QUESTION")
        }
    }
    /*
     * FUNCTION: addImage
     * PURPOSE: Opens the camera for user to attatch an image to there issue
     */
    @IBAction func addImage(_ sender: Any)
    {
            CameraHandler.shared.showActionSheet(vc: self)
            CameraHandler.shared.imagePickedBlock = { (image) in
                //self.issueImage.image = image
                self.thisImage = image
                self.issueImage.isHidden = false
                self.openEditor()
            }
        }
        /*
         * FUNCTION: openEditor
         * PURPOSE: Opens a screen with the current image displayed and access to editing tools
         */
        func openEditor()
        {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageEditor") as! ImageEditorViewController
            popOverVC.currentImage = self.thisImage
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            popOverVC.onEditorClosed = onEditorClosed
        }
        /*
         * FUNCTION: compressImage
         * PURPOSE: Compresses the image to reduce the size for storage
         */
        func compressImage(image: UIImage)
        {
            if let imageData = image.jpeg(.lowest)
            {
                print(imageData.count, "Bytes")
                thisImage = UIImage(data: imageData)!
            }
        }
        /*
         * FUNCTION: onEditorClosed
         * PURPOSE: Callback function called when image editor closed that updates the current image to the edited image
         */
        func onEditorClosed(_ image: UIImage)
        {
            thisImage = image
            compressImage(image: image)
            issueImage.image = thisImage
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
     * FUNCTION: okPressed
     * PURPOSE: Sets response to variant to ok
     */
    @IBAction func okPressed(_ sender: Any)
    {
        print("Ok Pressed")
        startActivity()
        DispatchQueue.global().async {
            
            if(!self.userInSkippedBank())
            {
                self.setResponse(atPosition: self.machine.thisPDI.thisQuestion, to: 1)
            }
            else
            {
                self.setResponse(atPosition: self.machine.thisPDI.skippedVariantBank[self.machine.thisPDI.currentSkipped].position, to: 1)
                self.machine.thisPDI.skippedVariantBank[self.machine.thisPDI.currentSkipped].response = 1
            }
            
            DispatchQueue.main.async
                {
                    self.stopActivity()
                    self.selectOk()
            }
        }
    }
    /* FUNCTION: notOkPressed
     * PURPOSE: Sets response to variant to not ok
     */
    @IBAction func notOkPressed(_ sender: Any)
    {
        print("Not Ok Pressed")
        startActivity()
        DispatchQueue.global().async {
            
            if(!self.userInSkippedBank())
            {
                self.setResponse(atPosition: self.machine.thisPDI.thisQuestion, to: 2)
            }
            else
            {
                self.setResponse(atPosition: self.machine.thisPDI.skippedVariantBank[self.machine.thisPDI.currentSkipped].position, to: 2)
                self.machine.thisPDI.skippedVariantBank[self.machine.thisPDI.currentSkipped].response = 2
            }
            
            DispatchQueue.main.async
            {
                    self.stopActivity()
                    self.selectNotOk()
            }
        }
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
    /*
     * FUNCTION: showList
     * PURPOSE: Calls a pop up window that will display the current user added issue in the pdi
     */
    @IBAction func showList(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newIssuesPopUp") as! newIssuesPopUpViewController
        popOverVC.Port = Port
        popOverVC.machine = machine
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
        self.view.bringSubview(toFront: loadingView)
        self.view = loadingView
        print("Loading screen succeeded")
    }
    /*
     * FUNCTION: nextPressed
     * PURPOSE: Moves to segment of the PDI
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        print("Next Pressed")
       if(userInSkippedBank())
       {
            // User is in skipped bank
            print("Saving Response in Skipped bank...")
        machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].response = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
        
        // Sets ststus in database of the question in the main bank
        Port.setQuestionStatus(status: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].response, type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].num)
        
            Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
        
        // Reconfigures the skipped bank
            if(machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response != 0)
            {
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            if(machine.thisPDI.skippedVariantBank.count != 0 && machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response != 0)
            {
                //THIS IS BEING DONE TWICE, REVISE
            machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].response = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
        }
       else
       {
            // User is in main bank
            print("Saving Response in main bank...")
            Port.setQuestionStatus(status: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].response, type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].num)
            Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].num, issueType: 0)
        }
    
        if(Port.verifyCompletion(type: 0))
        {
            print("********** ALL VARIANTS ARE ANSWERED ************")
            machine.thisPDI.noSkippedVariants = true
        }
        else
        {
            print("********** SOME VARIANTS ARE STILL SKIPPED ************")
            machine.thisPDI.noSkippedVariants = false
        }
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
        if(machine.thisPDI.skippedVariantBank.count != 0)
        {
            answered = false
        }
        return answered
    }
    /*
     * FUNCTION: moreInfoPressed
     * PURPOSE: Displays a pop up window with more information on the current variant
     */
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
    func genPreviousVariant()
    {
        var loadsuccess = false
        var setsuccess = false
        if(!userInSkippedBank())
        {
            // User is in main bank
            let positionInMain = machine.thisPDI.thisQuestion
            decrementThisQuestion()
            
            if(lastQuestionIn(bank: 0, isAt: machine.thisPDI.thisQuestion) && machine.thisPDI.skippedVariantBank.count == 0)
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
            
            
            
            setsuccess = Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain].response, type: 0, id: machine.thisPDI.variantBank[positionInMain].num)
            
            Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain].num, issueType: 0)
            if(machine.thisPDI.variantBank[positionInMain].response != 0)
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
            }
            let success = genQuestion()
            if(!success)
            {
                print("ERROR GENERATEING NEXT QUESTION")
            }
        }
        else
        {
            // User is in skipped bank
            let positionInMain = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position
            
            // Sets question status in database and reconfigures issue list in the database to match
            let thisResponse = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response
            machine.thisPDI.variantBank[positionInMain!].response = thisResponse
            
            loadsuccess = Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position].id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
            if(!unanswered(atPosition: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position))
            {
                setsuccess = Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain!].response, type: 0, id: machine.thisPDI.variantBank[positionInMain!].num)
                Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain!].num, issueType: 0)
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            else
            {
                if(machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].response != 0)
                {
                    removeFromSkipped(index: machine.thisPDI.currentSkipped)
                }
            }
            
            // Puts user in the correct bank
            if(machine.thisPDI.currentSkipped == 0)
            {
                switchQuestionBanks()
                machine.thisPDI.thisQuestion = machine.thisPDI.variantBank.count - 1
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
        if(setsuccess)
        {
            print("Saved To Database")
        }
        else
        {
            showMessage(output: "Response could not be saved! Attempting reconnection...")
            refresh()
        }
        if(loadsuccess)
        {
            print("Loaded response from Database")
        }
        else
        {
            showMessage(output: "Saved response could not be loaded!  Attempting reconnection...")
            refresh()
        }
    }
    /*
     * FUNCTION: backVariantPressed
     * PURPOSE: Gos back to previous variant
     */
    @IBAction func backVariantPressed(_ sender: Any)
    {
        print("Back Variant Pressed")
        startActivity()
        genPreviousVariant()
        stopActivity()
    }
    func genNextVariant()
    {
        //var loadsuccess = false
        var setsuccess = false
        if(userInSkippedBank())
        {
            // User is in skipped bank
            let positionInMain = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position
            if(!unanswered(atPosition: positionInMain!))
            {
                if(checkBoundsOf(bank: 1) && variantInSkipped(variantPosition: positionInMain!))
                {
                    removeFromSkipped(index: machine.thisPDI.currentSkipped)
                    print("REMOVED SKIPPED VARIANT AT: ", machine.thisPDI.currentSkipped)
                }
                setsuccess = Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain!].response, type: 0, id: machine.thisPDI.variantBank[positionInMain!].num)
                if(setsuccess)
                {
                    print("Saved To Database")
                }
                else
                {
                    showMessage(output: "Response could not be saved!  Attempting reconnection...")
                    refresh()
                }
                Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain!].num, issueType: 0)
            }
            else
            {
                machine.thisPDI.skippedVariantBank.append(machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped])
                removeFromSkipped(index: machine.thisPDI.currentSkipped)
            }
            if(notOk(atPosition: positionInMain!))
            {
                addIssueToDB(fromPosition: positionInMain!)
            }
        }
        else
        {
            // User is in main bank
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
                setsuccess = Port.setQuestionStatus(status: machine.thisPDI.variantBank[positionInMain].response, type: 0, id: machine.thisPDI.variantBank[positionInMain].num)
                Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[positionInMain].num, issueType: 0)
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
        
        if(setsuccess)
        {
            print("Saved To Database")
        }
        else
        {
            showMessage(output: "Response could not be saved!  Attempting reconnection...")
            refresh()
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
        
        startActivity()
        genNextVariant()
        
        if(!userInSkippedBank())
        {
            if(!lastQuestionIn(bank: 0, isAt: machine.thisPDI.thisQuestion))
            {
                incrementThisQuestion()
            }
            else
            {
                if(machine.thisPDI.skippedVariantBank.count == 0)
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
        else if(machine.thisPDI.skippedVariantBank.count == 1)
        {
            nextButton.isHidden = true
            genSkippedQuestion()
        }
        else
        {
            genSkippedQuestion()
        }
        stopActivity()
    }
    /*
     * FUNCTION: genQuestion
     * PURPOSE: Generates a new variant
     * RETURNS: true if generation was successful and false if an error was encountered
     */
    func genQuestion() -> Bool
    {
        var loadsuccess = false
        print("***---------------------------------------------------------***")
        print("Generateing Question")
        
        if(machine.thisPDI.variantBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.thisQuestion + 1)
            if(machine.thisPDI.thisQuestion < machine.thisPDI.variantBank.count)
            {
                if(machine.thisPDI.thisQuestion >= 0)
                {
                    loadsuccess = Port.updateSingleResponse(type: 0, id: machine.thisPDI.variantBank[machine.thisPDI.thisQuestion].id, index: machine.thisPDI.thisQuestion)
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
            if(loadsuccess)
            {
                print("Loaded response from Database")
            }
            else
            {
                showMessage(output: "Saved response could not be loaded!  Attempting reconnection...")
                refresh()
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
        var loadsuccess = false
        print("***---------------------------------------------------------***")
        print("Generateing Skipped Question...")
        if(machine.thisPDI.skippedVariantBank.count != 0)
        {
            currentNumberTag.text = String(describing: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position + 1)
            
            let newVariant = machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].variant
            loadsuccess = Port.updateSingleResponse(type: 0, id: newVariant.id, index: machine.thisPDI.skippedVariantBank[machine.thisPDI.currentSkipped].position)
            number.text = newVariant.num
            variantDescription.text = newVariant.message
            selectNone()
            if(loadsuccess)
            {
                print("Loaded response from Database")
            }
            else
            {
                showMessage(output: "Saved response could not be loaded!  Attempting reconnection...")
                refresh()
            }
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
        refreshSkipped()
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
    func refreshSkipped()
    {
        Port.refreshList(type: 0)
        machine.thisPDI.skippedVariantBank = Port.skippedVariantArray
    }
    /*
     * FUNCTION: onJumpPressed
     * PURPOSE: Callback function that is executed upon skipped list pop up window being closed to relay the selcted position to move to
     * PARAMS: jumpPos -> Position to move to in the main bank
     */
    func onJumpPressed(_ jumpPos: Int)
    {
        print("Jumping to: ", jumpPos)
        if(jumpPos >= 0)
        {
            if(jumpPos < machine.thisPDI.variantBank.count - 1)
            {
                nextButton.isHidden = false
            }
            else
            {
                nextButton.isHidden = true
            }
            if(jumpPos > 0)
            {
                backButton.isHidden = false
            }
            else
            {
                backButton.isHidden = true
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
     * PURPOSE: Checks if the indicated variant has been answered
     * PARAMS: atPosition -> Position of the variant in the main bank to be checked
     * RETURNS: true if the variant has not been answered and false if it has an answer
     */
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
    /*
     * FUNCTION: notOk
     * PURPOSE: Checks to see if the indicated variant is not ok
     * PARAMS: atPosition -> Position in the main bank of the variant whose response is to be checked
     * RETURNS: true if the response is not ok and false if the response is anything else
     */
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
     * PURPOSE: Sets the response of the variant at the given position to the given response
     * PARAMS: atPosition -> Position of variant to set response of in main bank
     *         to -> Response to be assigned to the given variant
     */
    func setResponse(atPosition: Int, to: Int)
    {
        print("Setting response at: ", atPosition, " to:", to)
        machine.thisPDI.variantBank[atPosition].response = to
    }
    /*
     * FUNCTION: response
     * PURPOSE: Returns the response to the variant at the given position in the main bank
     * PARAMS: atPosition -> position of desired response
     * RETURNS: the response to the variant at the given position
     */
    func response(atPosition: Int) -> Int
    {
        print("Getting response...")
        return machine.thisPDI.variantBank[atPosition].response
    }
    /*
     * FUNCTION: lastQuestionIn
     * PURPOSE: Checks if the given position is the last quetion in  the indicated bank
     * PARAMS: bank -> indicates whether to check the main bank or the skipped bank
     *          isAt -> Position in bank to check
     */
    func lastQuestionIn(bank: Int, isAt: Int) -> Bool
    {
        print("Checking if question is last...")
        var lastQuestion = false
        if(bank == 0)
        {
            if(isAt == machine.thisPDI.variantBank.count - 1)
            {
                print("LAST QUESTION FOUND AT: ", isAt)
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
    /*
     * FUNCTION: checkBoundsOf
     * PURPOSE: Checks to see if the current position is in bounds of the indicated bank
     * PARAMS: bank -> indicates whether the main banks bounds are to be checked or the skipped banks bounds
     */
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
    /*
     * FUNCTION: addIssueToDB
     * PURPOSE: Adds a variant issue to the machineCongigIssues array in the database and in the local issue bank
     * PARAMS: fromPosition -> Position in the main variant bank of variant to be added to the issues array
     */
    func addIssueToDB(fromPosition: Int)
    {
        machine.thisPDI.variantIssueBank.append(machine.thisPDI.variantBank[fromPosition])
        Port.removeIssue(issueIdentifier: machine.thisPDI.variantBank[fromPosition].num, issueType: 0)
        Port.addOneVariant(issue: machine.thisPDI.variantBank[fromPosition])
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
        view.bringSubview(toFront: checkConnectionButton)
        //view.bringSubview(toFront: refreshButton)
        
        if(xtoggle == 0)
        {
            // Menu is currently closed, opens menu
            cancelButton.isHidden = false
            saveButton.isHidden = false
            checkConnectionButton.isHidden = false
            //refreshButton.isHidden = false
            xtoggle = 1
        }
        else
        {
            // Menu is currently open, hides menu
            cancelButton.isHidden = true
            saveButton.isHidden = true
            checkConnectionButton.isHidden = true
            //refreshButton.isHidden = true
            xtoggle = 0
        }
    }
    /*
     * FUNCTION: saveExitPressed
     * PURPOSE: If the "Save & Exit" button is pressed, inspectedMachines object stays in database and pdiStatus remains set to "2", user is redirected to home screen
     */
    @IBAction func saveExitPressed(_ sender: Any)
    {
        activityIndicator = thisActivity
        showLoadingScreen()
        loadingText.text = "Saving PDI..."
        startActivity()
        loadingView.alpha = 1
        DispatchQueue.global().async {
            
            self.Port.setReturnPos(pos: "var")
            self.Port.macStatus(status: 2)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "variantsCancelToMain", sender: self.machine)
            }
        }
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
        activityIndicator = thisActivity
        showLoadingScreen()
        loadingText.text = "Canceling PDI..."
        startActivity()
        loadingView.alpha = 1
        DispatchQueue.global().async {
            
            self.Port.removeInspected()
            self.Port.macStatus(status: 0)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "variantsCancelToMain", sender: self.machine)
            }
        }
    }
    /*
     * FUNCTION: checkConnectionPressed
     * PURPOSE: Calls refresh when checkconnection button is pressed
     */
    @IBAction func checkConnectionPressed(_ sender: Any) {
        refresh()
    }
    /*
     * FUNCTION: refresh
     * PURPOSE: Attempts to reconnect to the database
     */
    func refresh()
    {
        startActivity()
        DispatchQueue.global().async
            {
                self.Port.reconnect()
                DispatchQueue.main.async {
                    self.stopActivity()
                    
                    if(self.Port.connected())
                    {
                        self.showMessage(output: "Connected to Database")
                    }
                    else
                    {
                        self.showMessage(output: "Not Connected to Database, Check that network is 'cwgast'")
                    }
                }
        }
    }
    /*
     * FUNCTION: showMessage
     * PURPOSE: Displays a pop-up with the given message
     * PARAMS: output -> string to output
     */
    func showMessage(output: String)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = output
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
                vc.Port = self.Port
            }
        }
        if segue.identifier == "VariantsBackToOM" {
            if let vc = segue.destination as? OMViewController {
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
