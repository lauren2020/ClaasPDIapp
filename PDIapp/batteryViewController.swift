//
//  batteryViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

/*
 * CLASS: batteryViewController
 * PURPOSE: Controls the screen that displays and operates battery input
 */
class batteryViewController: UIViewController, UITextFieldDelegate
{
    //BATTERIES DEPEND ON CONFIGURATION OF MACHINE TYPE
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending and retrieving data to and from the database
    var Port: port!
    //indicates whether pressing "X" should open or close drop down menu
    var xtoggle = 0
    //indicates whether bottom submission field elements should be configured to add a new issue or send a message to the wash bay
    var toggle = 0
    //indicates whether confirm was pressed
    var leftPressed = false
    //indicates whether change was pressed
    var rightPressed = false
    //the textbox currently being edited
    var currentField: UITextField?
    var lastIssueField: UITextField?
    //holds the issue message to be displayed if a constraint on the current field is violated
    var issue: String!
    //identifys the current battery
    var identifier: String!
    ////////var currentVC: UIViewController!
    // Display image for user to add image to new image
    var thisImage: UIImage!
    // Holds message to be sent to new issues on submit pressed
    var thisMessage = ""
    // Icon that indicates background activity to the user
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    //Object access identifiers
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var checkConnectionButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var loadingScreen: UIImageView!
    @IBOutlet weak var issueImage: UIImageView!
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
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var messageTitle: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        print("Battery View Loaded")
        machine.thisPDI.position = "bat"
        
        //retrieves saved battery responses from the database
        Port.setBatteries(machine: machine)
        
        //set textboxes to be there own delegates
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
        messageField.delegate = self

        //initialize screen elements
        cancelButton.isHidden = true
        saveButton.isHidden = true
        refreshButton.isHidden = true
        checkConnectionButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        
        //set battery configuration
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
    /*
     * FUNCTION: addImage
     * PURPOSE: Appends an image from either the camera or gallery to the current new issue
     */
    @IBAction func addImage(_ sender: Any)
    {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
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
     * FUNCTION: textFieldDidBeginEditing
     * PURPOSE: If text box editing is started, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        //sets the current identifier
        if(textField == C130)
        {
            identifier = "c13CCA"
        }
        else if(textField == C131)
        {
            identifier = "c13Volt"
        }
        else if(textField == G0010)
        {
            identifier = "g001CCA"
        }
        else if(textField == G0011)
        {
            identifier = "g001Volt"
        }
        else if(textField == G0050)
        {
            identifier = "g005CCA"
        }
        else if(textField == G0051)
        {
            identifier = "g005Volt"
        }
        else if(textField == G0040)
        {
            identifier = "g004CCA"
        }
        else if(textField == G0041)
        {
            identifier = "g004Volt"
        }
        else if(textField == messageField)
        {
            moveTextField(textField: messageField, moveDistance: -250, up: true)
        }
        
        
        //resets errors
        textField.backgroundColor = UIColor .white
        if(textField != messageField)
        {
            currentField = textField
            Port.removeIssue(issueIdentifier: identifier, issueType: 3)
            //Sets keyboard configuration
            textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
    }
    /*
     * FUNCTION: textFieldDidEndEditing
     * PURPOSE: If text box editing is ended, the current text is checked for compliance with constraints
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if(textField == C130)
        {
            if(!inputIsInt(field: textField) && !inputIsDouble(field: textField))
            {
                unsupportedInput()
            }
            else if(Double(textField.text!)! < 1200.0)
            {
                issue = "CCA is too low, battery should be scrapped"
                constraintViolated(warning: "CCA is too low, please confirm battery should be scrapped", field: textField)
            }
        }
        else if(textField == C131)
        {
            if(!inputIsInt(field: textField) && !inputIsDouble(field: textField))
            {
                if(textField.text != "")
                {
                    unsupportedInput()
                }
            }
            else if(Double(textField.text!)! <= 11.4)
            {
                issue = "Volt is too low, battery should be scrapped"
                constraintViolated(warning: "Volt is too low, please confirm battery should be scrapped", field: textField)
            }
            else if(Double(textField.text!)! > 11.4 && Double(textField.text!)! <= 12.6)
            {
                issue = "Volt is too low, battery should be reworked"
                constraintViolated(warning: "Volt is too low, please confirm battery should be reworked", field: textField)
            }
        }
        else if(textField == G0010 || textField == G0050 || textField == G0040)
        {
            if(!inputIsInt(field: textField) && !inputIsDouble(field: textField))
            {
                if(textField.text != "")
                {
                    unsupportedInput()
                }
            }
            else if(Double(textField.text!)! < 584.0)
            {
                issue = "CCA is too low, battery should be scrapped"
                constraintViolated(warning: "CCA is too low, please confirm battery should be scrapped", field: textField)
            }
        }
        else if(textField == G0011 || textField == G0051 || textField == G0041)
        {
            if(!inputIsInt(field: textField) && !inputIsDouble(field: textField))
            {
                if(textField.text != "")
                {
                    unsupportedInput()
                }
            }
            else if(Double(textField.text!)! <= 11.4)
            {
                issue = "Volt is too low, battery should be scrapped"
                constraintViolated(warning: "Volt is too low, please confirm battery should be scrapped", field: textField)
            }
            else if(Double(textField.text!)! > 11.4 && Double(textField.text!)! <= 12.6)
            {
                issue = "Volt is too low, battery should be reworked"
                constraintViolated(warning: "Volt is too low, please confirm battery should be reworked", field: textField)
            }
        }
        else if(textField == messageField)
        {
            moveTextField(textField: messageField, moveDistance: -250, up: false)
        }
    }
    
    /*
     * FUNCTION: inputIsInt
     * PURPOSE: Checks if the text in the bassed field is an integer value
     */
    func inputIsInt(field: UITextField) -> Bool
    {
        var isInt = false
        if let lat = field.text,
            let _ = Int(lat) {
            isInt = true
        }
        else
        {
            isInt = false
        }
        return isInt
    }
    /*
     * FUNCTION: inputIsDouble
     * PURPOSE: Checks if the text in the bassed field is a double value
     */
    func inputIsDouble(field: UITextField) -> Bool
    {
        var isDouble = false
        if let lat = field.text,
            let _ = Double(lat) {
            isDouble = true
        }
        else
        {
            isDouble = false
        }
        return isDouble
    }
    /*
     * FUNCTION: constraintViolated
     * PURPOSE: Displays a warning pop up if the text entered in the given textbox does not meet the constraints
     * PARAMS: warning -> the message to be displayed on the pop up with the specifics of the violation
     *          field -> the text box that contains the invalid entry
     */
    func constraintViolated(warning: String, field: UITextField)
    {
        lastIssueField = field
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "text2ButtonPopUp") as! Text2ButtonPopUpViewController
        popOverVC.messageIn = warning
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onPopOptionPressed = onPopOptionPressed
        
        print("Left Pressed: ", leftPressed)
        print("Right Pressed: ", rightPressed)
        
    }
    /*
     * FUNCTION: onPopOptionPressed
     * PURPOSE: When the violated constraints popup is closed, this callback function is excuted to relay to this view controller which option in the pop up was selected.
     * PARAMS: selected -> indicates which button was pressed, 0 == Confirm - 1 == Change
     */
    func onPopOptionPressed(_ selected: Int)
    {
        print("OnPopOption Entered: ", selected)
        if(selected == 0)
        {
            leftPressed = true
            rightPressed = false
            var issueToAdd = issue
            issueToAdd?.append(" - Value: ")
            issueToAdd?.append((lastIssueField?.text)!)
            Port.addBatteryIssue(issueIdentifier: identifier, issue: issueToAdd!)
            lastIssueField?.backgroundColor = UIColor .yellow
        }
        else if(selected == 1)
        {
            rightPressed = true
            leftPressed = false
            currentField?.text = ""
        }
    }
    /*
     * FUNCTION: unsupportedInput
     * PURPOSE: If text entered in field is not numeric a pop up window alerts the user and resets the text field
     */
    func unsupportedInput()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = "Only numeric input is supported"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        currentField?.text = ""
    }
    
    
    /*
     * FUNCTION: nextPressed
     * PURPOSE: This function updates the battery values in the PDI based on the content of the fields and proceeds to next scene
    */
    @IBAction func nextPressed(_ sender: Any)
    {
        print("Next Pressed")
        saveEntries()
        self.performSegue(withIdentifier: "batteryToOm", sender: machine)
    }
    /*
     * FUNCTION: saveEntries
     * PURPOSE: Saves current battery entries in the machines pdi object
     */
    func saveEntries()
    {
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
        Port.pushBattery()
    }
    /*
     * FUNCTION: c13Config
     * PURPOSE: Sets the battery field configuration to only show fields that apply to the c13 battery
     */
    func c13Config()
    {
        C130.isHidden = false
        if(machine.thisPDI.C13[0] != "nil")
        {
            C130.text = machine.thisPDI.C13[0]
        }
        if(Port.batteryHasIssue(type: "battC13CCA", constraint: 1200))
        {
            C130.backgroundColor = UIColor .yellow
        }
        C131.isHidden = false
        if(machine.thisPDI.C13[1] != "nil")
        {
            C131.text = machine.thisPDI.C13[1]
        }
        if(Port.batteryHasIssue(type: "battC13Volt", constraint: 12.7))
        {
            C131.backgroundColor = UIColor .yellow
        }
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
    /*
     * FUNCTION: mercedesConfig
     * PURPOSE: Sets the battery field configuration to only show fields that apply to the mercedes battery
     */
    func mercedesConfig()
    {
        C130.isHidden = true
        C131.isHidden = true
        G0010.isHidden = false
        G0010.text = machine.thisPDI.G001[0]
        if(Port.batteryHasIssue(type: "mtuG001CCA", constraint: 584))
        {
            G0010.backgroundColor = UIColor .yellow
        }
        G0011.isHidden = false
        G0011.text = machine.thisPDI.G001[1]
        if(Port.batteryHasIssue(type: "mtuG001Volt", constraint: 12.7))
        {
            G0011.backgroundColor = UIColor .yellow
        }
        G0050.isHidden = false
        G0050.text = machine.thisPDI.G005[0]
        if(Port.batteryHasIssue(type: "mtuG005CCA", constraint: 584))
        {
            G0050.backgroundColor = UIColor .yellow
        }
        G0051.isHidden = false
        G0051.text = machine.thisPDI.G005[1]
        if(Port.batteryHasIssue(type: "mtuG005Volt", constraint: 12.7))
        {
            G0051.backgroundColor = UIColor .yellow
        }
        G0040.isHidden = false
        G0040.text = machine.thisPDI.G004[0]
        if(Port.batteryHasIssue(type: "mtuG004CCA", constraint: 584))
        {
            G0040.backgroundColor = UIColor .yellow
        }
        G0041.isHidden = false
        G0041.text = machine.thisPDI.G004[1]
        if(Port.batteryHasIssue(type: "mtuG004Volt", constraint: 12.7))
        {
            G0041.backgroundColor = UIColor .yellow
        }
        MAN10.isHidden = true
        MAN11.isHidden = true
        MAN20.isHidden = true
        MAN21.isHidden = true
    }
    /*
     * FUNCTION: manConfig
     * PURPOSE: Sets the battery field configuration to only show fields that apply to the MAN battery
     */
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
        if(machine.thisPDI.MAN1[0] != "nil")
        {
            MAN10.text = machine.thisPDI.MAN1[0]
        }
        MAN11.isHidden = false
        if(machine.thisPDI.MAN1[1] != "nil")
        {
            MAN11.text = machine.thisPDI.MAN1[1]
        }
        MAN20.isHidden = false
        if(machine.thisPDI.MAN2[0] != "nil")
        {
            MAN20.text = machine.thisPDI.MAN2[0]
        }
        MAN21.isHidden = false
        if(machine.thisPDI.MAN2[1] != "nil")
        {
            MAN21.text = machine.thisPDI.MAN2[1]
        }
    }
    /*
     * FUNCTION: togglePressed
     * PURPOSE: Changes whether the message will create an issue or send a message to wash bay when submit is pressed
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
     * PURPOSE: Depending on toggle value, either sends the message in the text field to the wash bay or adds a new issue to the pdi with the given issue text.
     */
    @IBAction func submitPressed(_ sender: Any)
    {
        print("Submit Pressed")
        startActivity()
        if(toggle == 0)
        {
            //Add issue
            let identifier = "omIssueNr"
            thisMessage = messageField.text!
            if(thisImage != nil)
            {
                DispatchQueue.global().async {
                    
                    self.Port.addIssue2(issueIdentifier: identifier, issue: self.thisMessage, image: self.thisImage)
                    self.thisImage = nil
                    
                    DispatchQueue.main.async {
                        self.stopActivity()
                    }
                }
            }
            else
            {
                Port.addIssue(issueIdentifier: identifier, issue: messageField.text!)
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
        print("Activity Stoped")
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
     * FUNCTION: listPressed
     * PURPOSE: Calls a pop up window that will display the current user added issue in the pdi
     */
    @IBAction func listPressed(_ sender: Any)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newIssuesPopUp") as! newIssuesPopUpViewController
        popOverVC.Port = Port
        popOverVC.machine = machine
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
            
            self.saveEntries()
            self.Port.setReturnPos(pos: "bat")
            self.Port.macStatus(status: 2)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "batteryCancelToMain", sender: self.machine)
            }
        }
    }
    /*
     * FUNCTION: backPagePressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
    @IBAction func backPagePressed(_ sender: Any)
    {
        saveEntries()
        self.performSegue(withIdentifier: "batteryBackToFC", sender: machine)
    }
    
    /*
     * FUNCTION: cancelPressed
     * PURPOSE: Cancels the current PDI and returns to menu screen, this removes the machines object in the inspectedMachines collection and sets the pdiStatus in the "machinesReadyToGo" collection back to 0
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
                self.performSegue(withIdentifier: "batteryCancelToMain", sender: self.machine)
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
     * PURPOSE: This function sends current machine and individuals name onto OM scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "batteryToOm" {
            if let vc = segue.destination as? OMViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
            }
        }
        if segue.identifier == "batteryBackToFC" {
            if let vc = segue.destination as? FuelConsumptionViewController {
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
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case higher  = 0.9
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
