//
//  newIssuesPopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/19/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class newIssuesPopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var issuesList: UIPickerView!
    // Current issue selected
    var issue: Issue!
    // Array of new issue availible
    var issues = [Issue!]()
    // Connection point to database
    var Port: port!
    // Current machine being inspected
    var machine: Machine!
    
    var itemImage: UIImage!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        issuesList.delegate = self
        issuesList.dataSource = self
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        Port.fillNewIssues()
        issues = machine.thisPDI.newIssuesBank
        if(issues.count != 0)
        {
            issue = issues[0]
        }
        issuesList.reloadAllComponents()
        print("Loaded Issues: ", issues)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issues.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let rowLabel = UILabel()
        rowLabel.adjustsFontSizeToFitWidth = true
        rowLabel.text = issues[row].issueDescription
        return rowLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        startActivity()
        DispatchQueue.global().async {
            if(self.issues.count != 0)
        {
            self.issue = self.issues[row]
            if(self.issue.image != nil)
            {
                print("Image found")
                self.itemImage = UIImage(data: self.issue.image)
            }
            else if(self.issue.imageId != nil)
            {
                print("ImageId found")
                self.itemImage = self.Port.getImageFrom(id: self.issue.imageId)
                //self.displayImage()
            }
            else
            {
                print("no identifier found")
                self.itemImage = nil
            }
        }
            DispatchQueue.main.async {
                self.displayImage()
                self.stopActivity()
            }
        }
        //stopActivity()
    }
    func displayImage()
    {
        imageDisplay.image = itemImage
    }
    
    /*
     * FUNCTION: done
     * PURPOSE: Closes pop up with list of new issues
     */
    @IBAction func done(_ sender: Any)
    {
        self.view.removeFromSuperview()
    }
    /*
     * FUNCTION: deleteSelected
     * PURPOSE: Deletes the currently selected issue
     */
    @IBAction func deleteSelected(_ sender: Any)
    {
        if(issue != nil)
        {
            print("**************issue != nil**********************")
            Port.removeIssue(issueIdentifier: issue.id, issueType: 2)
            if(issue.imageId != nil)
            {
                Port.removeImageFrom(id: issue.imageId)
            }
            
        }
        Port.fillNewIssues()
        issues = machine.thisPDI.newIssuesBank
        issuesList.reloadAllComponents()
        if(issues.count == 1)
        {
            issue = issues[0]
        }
    }
    func startActivity()
    {
        print("Activity Started")
        //view.alpha = 0.5
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    func stopActivity()
    {
        print("Activity Stopped")
        //view.alpha = 1
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
