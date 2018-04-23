//
//  ContainerViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/6/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController
{
    //BATTERIES DEPEND ON CONFIGURATION OF MACHINE TYPE
    //holds the current machine being checked
    var machine: Machine!
    //holds the name of the individual completeing the current PDI
    var name: String!
    //port for sending and retrieving data to and from the database
    var Port: port!
    
    var vcIndex = 0
    var xtoggle = 0
    var toggle = 0
    var currentVC: UIViewController!
    var thisImage: UIImage!
    
//    var currentDelegate: SegueHandler!
    
   // @IBOutlet var segmentedControl: UISegmentedControl

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveExitButton: UIButton!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var issueImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Main Container View Loaded")
        print("MAIN MACHINE: ", machine)
        
        
      //  setUpViews()
        
        cancelButton.isHidden = true
        saveExitButton.isHidden = true
        currentVC = machine.thisPDI.vcs[0].vc
        
        //self.performSegue(withIdentifier: "containerToFC", sender: machine)
        // Do any additional setup after loading the view.
    }
  /*  private func setUpViews()
    {
        //private lazy var loginViewController: loginViewController = {
            // Load Storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
            // Instantiate View Controller
            var viewController = storyboard.instantiateViewController(withIdentifier: "ifc") as! FuelConsumptionViewController
        
            // Add View Controller as Child View Controller
            self.add(asChildViewController: viewController)
        
            return viewController
        //}()
    }
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
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
        // moveTextField(textField: messageField, moveDistance: -250, up: true)
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
         //moveTextField(textField: messageField, moveDistance: -250, up: false)
         }
    }
    @IBAction func backPage(_ sender: Any)
    {
        if(vcIndex == 1)
        {
            backButton.isHidden = true
        }
        if(vcIndex != 0)
        {
            vcIndex = vcIndex - 1
        }
        currentVC = machine.thisPDI.vcs[vcIndex].vc
        currentVC.performSegue(withIdentifier: machine.thisPDI.vcs[vcIndex].backSegue, sender: machine)
    }
    @IBAction func nextPage(_ sender: Any)
    {
        print("CurrentVC:", currentVC)
        
        //currentDelegate.segueToNext("FCtoBattery")
        
        //currentVC = machine.thisPDI.vcs[vcIndex].vc
        let success = true//currentVC.saveEntries(currentVC)
        /*if(success)
        {
           // FuelConsumptionViewController.performSegue(withIdentifier: "FCtoBattery", sender: machine)
            currentVC.performSegue(withIdentifier: machine.thisPDI.vcs[vcIndex].nextSegue, sender: machine)
        }*/
        if(vcIndex == machine.thisPDI.vcs.count - 2)
        {
            nextButton.isHidden = true
        }
        if(vcIndex != machine.thisPDI.vcs.count - 1)
        {
            vcIndex = vcIndex + 1
        }
        currentVC = machine.thisPDI.vcs[vcIndex].vc
        
    }
    @IBAction func openCloseMenu(_ sender: Any)
    {
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: saveExitButton)
        
        if(xtoggle == 0)
        {
            cancelButton.isHidden = false
            saveExitButton.isHidden = false
            xtoggle = 1
        }
        else
        {
            cancelButton.isHidden = true
            saveExitButton.isHidden = true
            xtoggle = 0
        }
    }
    @IBAction func cancel(_ sender: Any)
    {
        print("Cancel Pressed")
        Port.removeInspected()
        Port.macStatus(status: 0)
        self.performSegue(withIdentifier: "containerToMain", sender: machine)
    }
    @IBAction func saveAndExit(_ sender: Any)
    {
        print("Save & Exit Pressed")
        //saveEntries()
        Port.setReturnPos(pos: machine.thisPDI.position)
        Port.macStatus(status: 2)
        self.performSegue(withIdentifier: "containerToMain", sender: machine)
    }
    @IBAction func addImage(_ sender: Any)
    {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.issueImage.image = image
            self.thisImage = image
            self.issueImage.isHidden = false
        }
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
    @IBAction func toggleMessageDestination(_ sender: Any)
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
    @IBAction func submitMessage(_ sender: Any)
    {
        print("Submit Pressed")
        if(toggle == 0)
        {
            //Add issue
            let identifier = "omIssueNr"
            if(thisImage != nil)
            {
                Port.addIssue2(issueIdentifier: identifier, issue: messageField.text!, image: thisImage)
                thisImage = nil
            }
            else
            {
                Port.addIssue(issueIdentifier: identifier, issue: messageField.text!)
            }
            issueImage.isHidden = true
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
     * FUNCTION: preare
     * PURPOSE: This function sends current machine and individuals name onto Battery scene
     * PARAMS: Machine machine - current machine PDI is being performed on
     *              String name - Name of the individual completeing the PDI
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "containerToFC"
        {
            if let vc = segue.destination as? FuelConsumptionViewController
            {
                //Sends selected machine and name of user to next segment
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to FC")
            }
        }
        if segue.identifier == "FCtoBattery"
        {
            if let vc = segue.destination as? batteryViewController
            {
                //Sends selected machine and name of user to next segment
                //vc.delegate = self
                vc.machine = self.machine
                vc.name = self.name
                vc.Port = self.Port
                print("exportDat Object Passed to FC")
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
