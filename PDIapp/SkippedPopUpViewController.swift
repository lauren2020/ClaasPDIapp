//
//  SkippedPopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class SkippedPopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var type = 0
    var message = "None Skipped"
    var bank: [SkippedVariant]!
    var bank2: [SkippedCheckpoint]!
    var thisVariant: SkippedVariant!
    var thisCheckpoint: SkippedCheckpoint!
    
    var onJumpPressed: ((_ jumpPos: Int) -> ())?
    
    @IBOutlet weak var list: UILabel!
    @IBOutlet weak var listScroller: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        listScroller.delegate = self
        listScroller.dataSource = self
        
        if(type == 0)
        {
            if(bank.count != 0)
            {
                thisVariant = bank[0]
            }
        }
        else
        {
            if(bank2.count != 0)
            {
                thisCheckpoint = bank2[0]
                
                var sortedAboveIndex = bank2.count // Assume all values are not in order
                repeat {
                    var lastSwapIndex = 0
                    for i in 1 ..< sortedAboveIndex
                    {
                        let b4 = i - 1
                        if (bank2[b4].checkpoint.position > bank2[i].checkpoint.position)
                        {
                            let store = bank2[i]
                            bank2[i] = bank2[b4]
                            bank2[b4] = store
                            lastSwapIndex = i
                        }
                    }
                    sortedAboveIndex = lastSwapIndex
                    
                } while (sortedAboveIndex != 0)
            }
        }
        
        list.text = message
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        listScroller.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if(type == 0)
        {
            return bank.count
        }
        else
        {
            return bank2.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if(type == 0)
        {
            var display = String(bank[row].variant.listPosition + 1)
            display.append(" : ")
            display.append(bank[row].variant.num)
            return display
        }
        else
        {
            var display = String(bank2[row].checkpoint.position + 1)
            display.append(" : ")
            display.append(bank2[row].checkpoint.failure)
            return display
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(type == 0)
        {
            if(bank.count != 0)
            {
                thisVariant = bank[row]
            }
        }
        else
        {
            if(bank2.count != 0)
            {
                thisCheckpoint = bank2[row]
            }
        }
        
    }
    
    
    @IBAction func okPressed(_ sender: Any)
    {
        self.view.removeFromSuperview()
    }
    @IBAction func jump(_ sender: Any)
    {
        var thisQuestion = -1
        
        if(type == 0)
        {
            if(bank.count != 0)
            {
                thisQuestion = thisVariant.position
            }
        }
        else
        {
            if(bank2.count != 0)
            {
                thisQuestion = thisCheckpoint.position
            }
        }
        
        onJumpPressed!(thisQuestion)
        
        self.view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
