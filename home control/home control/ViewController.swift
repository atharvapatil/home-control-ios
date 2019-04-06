//
//  ViewController.swift
//  home control
//
//  Created by Atharva Patil on 06/04/2019.
//  Copyright © 2019 Atharva Patil. All rights reserved.
//


//Importing the UI kit for asset development & Speech for speech detection
import UIKit
import Speech


class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {

    
    @IBOutlet weak var colourView: UIView!
    
    @IBOutlet weak var toggle: UIButton!
    
    var toggleState = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("This works")
        
        colourView.backgroundColor = .green
    }
    
    @IBAction func toggleTapped(_ sender: Any) {
        
        if(toggleState == false){
            colourView.backgroundColor = .red
            toggleState = true
        } else if(toggleState == true){
            colourView.backgroundColor = .blue
            toggleState = false
        }
        
    }
    
    
    
    


}

