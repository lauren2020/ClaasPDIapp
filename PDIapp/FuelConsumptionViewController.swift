//
//  FuelConsumptionViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/10/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class FuelConsumptionViewController: UIViewController, UITextFieldDelegate
{
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending data back to database
    var Port: port!
    //indicates whether pressing "X" should open or close drop down menu
    var xtoggle = 0
    // Icon that indicates background activity to the user
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fuelConsumptionBox: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet var tapScreen: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        machine.thisPDI.position = "ifc"

        Port.setInitialFuelConsumption(machine: machine)
        
        fuelConsumptionBox.delegate = self
        
        cancelButton.isHidden = true
        saveButton.isHidden = true
        machineLabel.text = machine.name
        nameLabel.text = name
        if(machine.thisPDI.initialFuelConsumption != nil)
        {
            fuelConsumptionBox.text = String(format:"%f", machine.thisPDI.initialFuelConsumption)
        }
        activityIndicator = thisActivity
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
     * FUNCTION: touchesBegan
     * PURPOSE: Is called when touch begins
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
     * FUNCTION: textFieldDidBeginEditing
     * PURPOSE: If text box editing is started, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
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
     * FUNCTION: nextPressed *
     * Purpose: The purpose of this function is to updatate info in this machines PDI and move to the next screen *
     */
    @IBAction func nextPressed(_ sender: Any)
    {
        //When next is pressed, this saves the begining fuel consumption
        let isFilled = fuelConsumptionBox.hasText
        var isDouble = false
        if let lat = fuelConsumptionBox.text,
            let _ = Double(lat) {
            isDouble = true
        }
        else
        {
            isDouble = false
        }
        if (isDouble && isFilled)
        {
            machine.thisPDI.setInitialFuelConsumption(fuelConsumptionIn: Double(fuelConsumptionBox.text!)!)
            Port.pushInitialFuelConsumption()
            self.performSegue(withIdentifier: "FCtoBattery", sender: machine)
        }
        else
        {
            //if fuel consumption entry is empty or not valid, message appears in box
            fuelConsumptionBox.text = ""
            fuelConsumptionBox.placeholder = "enter a number"
            unsupportedInput()
        }
    }
    /*
     * FUNCTION: unsupportedInput
     * PURPOSE: If text entered in field is not numeric a pop up window alerts the user and resets the text field
     */
    func unsupportedInput()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = "Please enter a number"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        fuelConsumptionBox.text = ""
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
        let isFilled = fuelConsumptionBox.hasText
        var isDouble = false
        if let lat = fuelConsumptionBox.text,
            let _ = Double(lat) {
            isDouble = true
        }
        else
        {
            isDouble = false
        }
        
        showLoadingScreen()
        startActivity()
        
        loadingText.text = "Saving PDI..."
        DispatchQueue.global().async {
            
            if (isDouble && isFilled)
            {
                self.machine.thisPDI.setInitialFuelConsumption(fuelConsumptionIn: Double(self.fuelConsumptionBox.text!)!)
                self.Port.pushInitialFuelConsumption()
            }
            self.Port.setReturnPos(pos: "ifc")
            self.Port.macStatus(status: 2)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "fcCancelToMain", sender: self.machine)
            }
        }
    }
    
    
    /*
     * FUNCITON: cancelPressed
     * PURPOSE: Cancels the current PDI
    */
    @IBAction func cancelPressed(_ sender: Any)
    {
        showLoadingScreen()
        startActivity()
        
        loadingText.text = "Canceling PDI..."
        DispatchQueue.global().async {
            
            self.Port.removeInspected()
            self.Port.macStatus(status: 0)
            DispatchQueue.main.async {
                self.stopActivity()
                self.performSegue(withIdentifier: "fcCancelToMain", sender: self.machine)
            }
        }
    }
    
    /*
     * FUNCTION: prepare
     * PURPOSE: This function sends current machine and individuals name onto Battery scene
     * VARIABLES: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FCtoBattery" {
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
