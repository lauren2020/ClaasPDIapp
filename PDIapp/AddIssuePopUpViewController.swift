//
//  AddIssuePopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/21/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class AddIssuePopUpViewController: UIViewController
{
    // Connetion point to database
    var Port: port!
    // Identifys whether message should go to issue bank or washbay
    var toggle = 0
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    @IBAction func switchType(_ sender: Any)
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
    @IBAction func submit(_ sender: Any)
    {
        print("Submit Pressed")
        if(toggle == 0)
        {
            //Add issue
            let identifier = "omIssueNr"
            Port.addIssue(issueIdentifier: identifier, issue: messageField.text!)
            print("ADDED ISSUE")
        }
        else
        {
            //Send Message to wash bay
            Port.sendMessageToWashBay(message: messageField.text!)
            print("SENT MESSAGE TO WASH BAY")
        }
        messageField.text = ""
        self.view.removeFromSuperview()
    }
    @IBAction func close(_ sender: Any)
    {
        self.view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
