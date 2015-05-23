//
//  ViewController.swift
//  pH Calculator
//
//  Created by Tim Snow on 22/05/2015.
//  Copyright (c) 2015 Tim Snow. All rights reserved.
//


import Cocoa


class ViewController: NSViewController, NSTextFieldDelegate {
	
	
	// Delcaring IBOutlets from the storyboard
    @IBOutlet weak var currentphInputField: NSTextField!
    @IBOutlet weak var targetphInputField: NSTextField!

    @IBOutlet weak var adjustmentVolumeLabel: NSTextField!
    
    @IBOutlet weak var volumeToAdjustInputField: NSTextField!
    @IBOutlet weak var adjustorphInputField: NSTextField!
    
    
	// If the view loaded, let's initialise with some default values and start listening...
	override func viewDidLoad() {
		super.viewDidLoad()
        
        currentphInputField.delegate = self
        currentphInputField.stringValue = "0"
        
        targetphInputField.delegate = self
        targetphInputField.stringValue = "0"
        
        adjustmentVolumeLabel.stringValue = "0"
        
        volumeToAdjustInputField.delegate = self
        volumeToAdjustInputField.stringValue = "1"
        
        adjustorphInputField.delegate = self
        adjustorphInputField.stringValue = "0"

        // Update the labels with some calculated values
        phAdjustment()
	}

	
	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


   override func controlTextDidChange (notification: NSNotification) {
		// Listen for NSNotifications when the input field values change and handle them
		if notification.object?.description == currentphInputField.description {
			phAdjustment()
		}
		
		if notification.object?.description == targetphInputField.description {
			phAdjustment()
		}
		
		if notification.object?.description == volumeToAdjustInputField.description {
			phAdjustment()
		}
    
        if notification.object?.description == adjustorphInputField.description {
            phAdjustment()
        }
    }


	func phAdjustment() {
		// Do some maths based on the user input
		// Start by getting the values from the input fields and converting them to floats
		var currentph = (currentphInputField.stringValue as NSString).floatValue
		var targetph = (targetphInputField.stringValue as NSString).floatValue
        var volumeToAdjust = (volumeToAdjustInputField.stringValue as NSString).floatValue
        var adjustorph = (adjustorphInputField.stringValue as NSString).floatValue
		
        var currentH, targetH, diffH, adjustorH, additionalH, neutralisationH, result: Float
        
		// Then do the maths
        // Adjustor pH greater than 7 (Bases)
        if adjustorph > 7 {
            // Work out the concentration of the adjustor
            adjustorH = pow(10, -(14 - adjustorph))
            
            // If we need to neutralise any acidic content first
            if currentph < 7 {
                if targetph > currentph {
                    // If we need to neutralise a bit, but not all of the acidic content
                    if targetph < 7 {
                        currentH = pow(10, -currentph)
                        targetH = pow(10, -targetph)
                        diffH = currentH - targetH
                    }
                    // If we need to neutralise all of the acid and add more base too
                    else {
                        neutralisationH = pow(10, -currentph)
                        targetH = pow(10, -(14 - targetph))
                        diffH = neutralisationH + targetH
                    }
                }
                // Can't make solutions more acidic
                else {
                    diffH = -1
                }
            }
            // If it's easy and all we need to do is add more base
            else {
                targetH = pow(10, -(14 - targetph))
                currentH = pow(10, -(14 - currentph))
                diffH =  targetH - currentH
            }
        }
        // Adjustor pH lesser than 7 (Acids)
        else  {
            // Work out the concentration of the adjustor
            adjustorH = pow(10, -adjustorph)

            // If we need to neutralise any basic content first
            if currentph > 7 {
                if targetph < currentph {
                    // If we need to neutralise a bit, but not all of the basic content
                    if targetph > 7 {
                        currentH = pow(10, -(14 - currentph))
                        targetH = pow(10, -(14 - targetph))
                        diffH = currentH + targetH
                    }
                    // If we need to neutralise all of the base and add more acid too
                    else {
                        neutralisationH = pow(10, -(14 - currentph))
                        targetH = pow(10, -targetph)
                        diffH = neutralisationH + targetH
                    }
                }
                // Can't make solutions more basic
                else {
                    diffH = -1
                }
            }
            // If it's easy and all we need to do is add more acid
            else {
                currentH = pow(10, -currentph)
                targetH = pow(10, -targetph)
                diffH = targetH - currentH
            }
        }
        
        // Finally calculate the result
		result = (diffH / adjustorH) * volumeToAdjust * 1000
		
		// Then update the label appropriately, it's either possible...
        if result >= 0 {
            adjustmentVolumeLabel.stringValue = String(format: "%5.3f", result)
        }
        // Or it's not
        else {
            adjustmentVolumeLabel.stringValue = "Not possible with adjustor"
        }
	}
}

