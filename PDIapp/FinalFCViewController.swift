//
//  FinalFCViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class FinalFCViewController: UIViewController, UITextFieldDelegate
{
    //Machine object currently being inspected
    var machine: Machine!
    //Name of user performing pdi
    var name: String!
    //Holds the value of the final fuel consumption
    var finalFC: Double!
    //Connection point to database
    var Port: port!
    // Creates activity indicator object
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Displays the current machines ID
    @IBOutlet weak var machineLabel: UILabel!
    // Displays the current users name
    @IBOutlet weak var nameLabel: UILabel!
    // Text field for getting final fuel consumption from user
    @IBOutlet weak var finalFCField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Final FC View Loaded")
        
        // Sets return position in database
        machine.thisPDI.position = "ffc"
        
        finalFCField.delegate = self
        
        //intializes screen elements
        machineLabel.text = machine.name
        nameLabel.text = name
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
     * FUNCTION: backPressed
     * PURPOSE: If the back button is pressed, returns user to previous screen
     */
    @IBAction func backPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "FFCBackToCheckpoints", sender: machine)
    }
    /*
     * FUNCTION: completePressed
     * PURPOSE: Verifys fuel consumption input is valid and sends the results to the database and marks the machine as completed
     */
    @IBAction func completePressed(_ sender: Any)
    {
        print("Complete Pressed")
        
        let isFilled = finalFCField.hasText
        var isDouble = false
        if let lat = finalFCField.text,
            let _ = Double(lat) {
            isDouble = true
        }
        if (isDouble && isFilled)
        {
            var successsend = false
            startActivity()
            DispatchQueue.global().async {
                
                self.machine.thisPDI.setFinalFuelConsumption(fuelConsumptionIn: Double(self.finalFCField.text!)!)
                //send pdi results to db
                successsend = self.Port.pushFinalFuelConsumption()
                //Set status to complete
                self.Port.macStatus(status: 1)
                DispatchQueue.main.async {
                    self.stopActivity()
                    if(successsend)
                    {
                        self.performSegue(withIdentifier: "ffcToMain", sender: self.machine)
                        print("ALL DATA EXPORTED")
                    }
                    else
                    {
                        self.showMessage(output: "Fuel consumption could not be saved. Attempting to reconnect...")
                        self.refresh()
                    }
                    }
            }
        }
        else
        {
            // Displays pop up warning that input was formatted incorrectly
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
            popOverVC.message = "Response must be a number"
            self.addChildViewController(popOverVC)
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            finalFCField.text = ""
        }
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
        if segue.identifier == "FFCBackToCheckpoints" {
            if let vc = segue.destination as? PDIViewController {
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
