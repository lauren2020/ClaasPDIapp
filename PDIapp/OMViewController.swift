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
    //port for sending and recieving data to and from the database
    var Port: port!
    //indicates whether pressing "X" should open or close drop down menu
    var xtoggle = 0
    var issueNumber = 1
    // Indicates which field is currently being manipulated
    var currentField = 0
    // Holds images user appends to a new issue
    var thisImage: UIImage!
    // Indicates how many "pages" (with 8 omms to a page) the current machines omms fill
    var pageCount = 0;
    // Indicates which set of omms on currently being evaluated
    var currentPage = 0;
    // Identifys the textfield to collect "main" input
    var omMainField: UITextField!
    // Identifys the textfield to collect "supp" input
    var omSuppField: UITextField!
    // Identifys the textfield to collect "fitting" input
    var omFittingField: UITextField!
    // Identifys the textfield to collect "cemos" input
    var omCemosField: UITextField!
    // Identifys the textfield to collect "terraTrack" input
    var omTeraTrackField: UITextField!
    // Identifys the textfield to collect "profiCam" input
    var omProfiCamField: UITextField!
    // Identifys the textfield to collect "Touch" input
    var omTouchField: UITextField!
    // Identifys the textfield to collect "Dual" input
    var omDualField: UITextField!
    // Holds the message to be sent to new issues on submit pressed
    var thisMessage = ""
    // Icon that indicates background activity to the user
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    //Object access identifiers
    @IBOutlet weak var checkConnectionButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var issueImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var field2: UITextField!
    @IBOutlet weak var tag3: UIButton!
    @IBOutlet weak var field3: UITextField!
    @IBOutlet weak var tag4: UIButton!
    @IBOutlet weak var field4: UITextField!
    @IBOutlet weak var tag5: UIButton!
    @IBOutlet weak var field5: UITextField!
    @IBOutlet weak var tag6: UIButton!
    @IBOutlet weak var field6: UITextField!
    @IBOutlet weak var tag7: UIButton!
    @IBOutlet weak var field7: UITextField!
    @IBOutlet weak var tag8: UIButton!
    @IBOutlet weak var field8: UITextField!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nextListButton: UIButton!
    @IBOutlet weak var backListButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("OMView Loaded")
        
        nextListButton.isHidden = true
        backListButton.isHidden = true
        
        // Sets return position for database
        machine.thisPDI.position = "omm"
        
        // Loads current OMM responses if any exist
        Port.setOMs(machine: machine, pdiCreated: true)
        
        // Assigns all included OMMs in the current pdi to there textfields and tags
        currentField = 0
        assignOMMs()
        
        
        field1.delegate = self
        field2.delegate = self
        field3.delegate = self
        field4.delegate = self
        field5.delegate = self
        field6.delegate = self
        field7.delegate = self
        field8.delegate = self

        messageField.delegate = self
        
        // Sets up visual screen elements
        cancelButton.isHidden = true
        saveButton.isHidden = true
        refreshButton.isHidden = true
        checkConnectionButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    /*
     * FUNCTION: textFieldShouldReturn
     * PURPOSE: When text field is done editing, resigns responder
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    /*
     * FUNCTION: backListPage
     * PURPOSE: Calls previous page to be loaded when back button is pressed
     */
    @IBAction func backListPage(_ sender: Any)
    {
        loadPreviousPage()
    }
    /*
     * FUNCTION: nextListPage
     * PURPOSE: Calls next page to be loaded when back button is presses
     */
    @IBAction func nextListPage(_ sender: Any)
    {
        loadNextPage()
    }
    /*
     * FUNCTION: loadNextPage
     * PURPOSE: Loads and assigns the next set of OMMs
     */
    func loadNextPage()
    {
        if(currentPage < pageCount)
        {
            saveEntries()
            currentPage += 1
            backListButton.isHidden = false
            assignOMMs()
        }
        else
        {
            nextListButton.isHidden = true
        }
    }
    /*
     * FUNCTION: loadPreviousPage
     * PURPOSE: Loads and assigns the previous set of OMMs
     */
    func loadPreviousPage()
    {
        if(currentPage > 0)
        {
            saveEntries()
            currentPage -= 1
            currentField = currentPage*8
            if(currentPage == 0)
            {
                backListButton.isHidden = true
            }
            assignOMMs()
        }
        else
        {
            backListButton.isHidden = true
        }
    }
    /*
     * FUNCTION: assingOMMs
     * PURPOSE: Assigns the text fields to the current set of omms
     */
    func assignOMMs()
    {
        // Creates an array of text fields that can be assigned to OMMs to retrieve ther values from the user
        var field = [field1, field2, field3, field4, field5, field6, field7, field8]
        // Creates an array of labels for each textfield that can be assigned OMMs to display there title
        var tag = [tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8]
        
        
        for index in currentField  - currentPage*8 ..< field.count
        {
            field[index]?.isHidden = false
            tag[index]?.isHidden = false
        }
        
        var ommsCount = 0
        for om in machine.thisPDI.omBank
        {
            if(om.included && currentField - currentPage*8 < 8 && ommsCount >= currentPage*8)
            {
                tag[currentField  - currentPage*8]?.setTitle(om.displayName, for: .normal)
                field[currentField  - currentPage*8]?.text = om.response
                om.field = currentField  - currentPage*8 + 1
                currentField += 1
            }
            else if(om.included && currentField - currentPage*8 >= 8 && ommsCount >= currentPage*8)
            {
                nextListButton.isHidden = false
                pageCount += 1
                break
            }
            if(om.included)
            {
                ommsCount += 1
            }
        }
        // Hides any textfields that are not assigned
        if(currentField - currentPage*8 < 8)
        {
            nextListButton.isHidden = true
            for index in currentField  - currentPage*8 ..< field.count
            {
                field[index]?.isHidden = true
                tag[index]?.isHidden = true
            }
        }
    }
    /*
     * FUNCTION: nextPressed
     * PURPOSE: Moves to the next segment of the PDI
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        if(field1.text == "" || field2.text == "" || field3.text == "" )
        {
            print("NOT ALL MANDATORY FIELDS HAVE BEEN COMPLETED")
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "'Main', 'Supp', and 'Unload' fields require input"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
        else
        {
            saveEntries()
            print("Next Pressed")
            self.performSegue(withIdentifier: "omToVariants", sender: machine)
        }
    }
    /*
     * FUNCTION: saveEntries
     * PURPOSE: Saves current battery entries in the machines pdi object
     */
    func saveEntries()
    {
        var ommsCount = 0;
        for om in machine.thisPDI.omBank
        {
            // Checks is current omm is within bounds of current view
            if(om.included && ommsCount < currentPage*8 + 8 && ommsCount >= currentPage*8)
            {
                om.response = getField(fieldId: om.field).text!
            }
            if(om.included)
            {
                ommsCount += 1
            }
        }
        Port.pushOM()
    }
    /*
     * FUNCTION: getField
     * PURPOSE: Returns the textfield associated with the indicated omm
     * PARAMS: fieldId -> indicates which omm
     * RETURNS: Textfield that matches passed id
     */
    func getField(fieldId: Int) -> UITextField
    {
        if(fieldId == 1)
        {
            return field1
        }
        else if(fieldId == 2)
        {
            return field2
        }
        else if(fieldId == 3)
        {
            return field3
        }
        else if(fieldId == 4)
        {
            return field4
        }
        else if(fieldId == 5)
        {
            return field5
        }
        else if(fieldId == 6)
        {
            return field6
        }
        else if(fieldId == 7)
        {
            return field7
        }
        else
        {
            return field8
        }
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
        else if(textField == field8)
        {
            moveTextField(textField: field8, moveDistance: -120, up: true)
        }
        else if(textField == field7)
        {
            moveTextField(textField: field7, moveDistance: -90, up: true)
        }
        else if(textField == field6)
        {
            moveTextField(textField: field6, moveDistance: -20, up: true)
        }
        
        if(textField != messageField)
        {
            textField.keyboardType = UIKeyboardType.numbersAndPunctuation
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
        else if(textField == field8)
        {
            moveTextField(textField: field8, moveDistance: -120, up: false)
        }
        else if(textField == field7)
        {
            moveTextField(textField: field7, moveDistance: -90, up: false)
        }
        else if(textField == field6)
        {
            moveTextField(textField: field6, moveDistance: -20, up: false)
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
     * FUNCTION: togglePressed
     * PURPOSE: Changes the message configuration between "Add Issue" and "Send message to wash bay"
     */
    @IBAction func togglePressed(_ sender: Any)
    {
        print("Toggle Pressed")
        if(toggle == 0)
        {
            // Switches to washbay mode
            messageTitle.text = "Message to Wash Bay"
            toggleButton.setTitle("Add Issue", for: .normal)
            toggle = 1
        }
        else
        {
            // Switches to issue mode
            messageTitle.text = "Add Issue"
            toggleButton.setTitle("Wash Bay", for: .normal)
            toggle = 0
        }
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
            var identifier = "omIssueNr"
            identifier.append(String(issueNumber))
            issueNumber += 1
            // Adds the current image to the issue
            startActivity()
            if(thisImage != nil)
            {
                thisMessage = messageField.text!
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
            self.Port.setReturnPos(pos: "omm")
            self.Port.macStatus(status: 2)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "omCancelToMain", sender: self.machine)
            }
        }
    }
    
    /*
     * FUNCTION: backPagePressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
    @IBAction func backpagePressed(_ sender: Any)
    {
        saveEntries()
        self.performSegue(withIdentifier: "OMBackToBattery", sender: machine)
    }
    
    /*
     * FUNCTION: cancelPressed
     * PURPOSE: Cancels the current PDI and returns to menu
     */
    @IBAction func omCancelToMain(_ sender: Any)
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
                self.performSegue(withIdentifier: "omCancelToMain", sender: self.machine)
            }
        }
    }
    /*
     * FUNCTION: checkConnectionPressed
     * PURPOSE: Calls refresh when checkconnection button is pressed
     */
    @IBAction func checkConnectionPressed(_ sender: Any) {
        refresh()
        if(self.Port.connected())
        {
            self.showMessage(output: "Connected to Database")
        }
        else
        {
            self.showMessage(output: "Not Connected to Database")
        }
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
     * PURPOSE: This function sends current machine and individuals name onto Variants scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "omToVariants" {
            if let vc = segue.destination as? VariantsViewController {
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
            }
        }
        if segue.identifier == "OMBackToBattery" {
            if let vc = segue.destination as? batteryViewController {
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
