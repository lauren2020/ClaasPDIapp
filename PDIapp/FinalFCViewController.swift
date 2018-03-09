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
    var machine: Machine!
    var name: String!
    var finalFC: Double!
    //port for sending data back to database
    var exportDat: exportData!
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var finalFCField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Final FC View Loaded")
        finalFCField.delegate = self
        machineLabel.text = machine.name
        nameLabel.text = name
        exportDat = exportData(machineIn: machine)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    @IBAction func backPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "FFCBackToCheckpoints", sender: machine)
    }
    
    @IBAction func completePressed(_ sender: Any)
    {
        print("Complete Pressed")
        let isFilled = finalFCField.hasText
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: finalFCField.text!))
        if (isNumber && isFilled)
        {
            machine.thisPDI.setFinalFuelConsumption(fuelConsumptionIn: Double(finalFCField.text!)!)
            //send pdi results to db
            exportDat.pushResults()
            //Set status to complete
            exportDat.macStatus(status: 1)
            print("ALL DATA EXPORTED")
        }
        else
        {
            finalFCField.text = "Enter a Number"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FFCBackToCheckpoints" {
            if let vc = segue.destination as? PDIViewController {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
