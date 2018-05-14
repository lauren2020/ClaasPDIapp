//
//  ImagesViewerViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/30/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class ImagesViewerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    // Connection point to the database
    var Port: port!
    // Array of images associated with the current machine
    var images = [Image]()
    // Array of machines that have images
    var machines = [Machine]()
    // Currently selcted machine
    var machine: Machine!
    // Currently selcted image
    var image: Image!

    // Picker View that holds machines with images
    @IBOutlet weak var machinesPicker: UIPickerView!
    // Picker view that holds images associated with the selected machine
    @IBOutlet weak var imagesPicker: UIPickerView!
    // Displayer view for the currently selected image
    @IBOutlet weak var imageDisplayer: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imagesPicker.delegate = self
        machinesPicker.delegate = self
        
        imagesPicker.reloadAllComponents()
        
        loadMachines()
        
        // Do any additional setup after loading the view.
    }
    /*
     * FUNCTION: loadMachines
     * PURPOSE: Gets all machines with pictures from database
     */
    func loadMachines()
    {
        machines = Port.getMachinesForIm()
        if(machines.count != 0)
        {
            machine = machines[0]
        }
        machinesPicker.reloadAllComponents()
        loadImages()
    }
    /*
     * FUNCTION: loadImages
     * PURPOSE: Fills the images picker with all the images associated with the selected machine
     */
    func loadImages()
    {
        if(machine.images != nil)
        {
            images = machine.images
            if(images.count != 0)
            {
                image = images[0]
                imageDisplayer.image = image.picture
            }
            imagesPicker.reloadAllComponents()
        }
        else
        {
            loadMachines()
        }
    }
    /**********************************************/
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        var count = 0;
        if(pickerView == machinesPicker)
        {
            count = machines.count
        }
        else
        {
            count = images.count
        }
        return count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let rowLabel = UILabel()
        if(pickerView == machinesPicker)
        {
            rowLabel.adjustsFontSizeToFitWidth = true
            rowLabel.text = machines[row].name
        }
        else
        {
            rowLabel.adjustsFontSizeToFitWidth = true
            if(images[row].message != "")
            {
                rowLabel.text = images[row].message
            }
            else
            {
                rowLabel.text = "No Message"
            }
        }
        return rowLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(pickerView == machinesPicker)
        {
            if(machines.count != 0)
            {
                machine = machines[row]
                loadImages()
            }
        }
        else
        {
            if(images.count != 0)
            {
                image = images[row]
                if(machine.images.count != 0)
                {
                    print("Image found")
                    imageDisplayer.image = image.picture
                }
                else
                {
                    print("no identifier found")
                    imageDisplayer.image = nil
                }
            }
        }
    }
    
    
    @IBAction func deleteImage(_ sender: Any)
    {
        var newImages: [Image]!
        for im in machine.images
        {
            if(im.imageId != image.imageId)
            {
                if(newImages != nil)
                {
                    newImages.append(im)
                }
                else
                {
                    newImages = [im]
                }
            }
        }
        for mac in machines
        {
            if(mac.name == machine.name)
            {
                mac.images = newImages
            }
        }
        Port.removeImageFrom2(id: image.uId)
        loadImages()
    }
    @IBAction func saveImageToCameraRoll(_ sender: Any)
    {
        UIImageWriteToSavedPhotosAlbum(image.picture, nil, nil, nil)
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = "Image Saved to Camera Roll"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    @IBAction func done(_ sender: Any)
    {
        self.view.removeFromSuperview()
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
