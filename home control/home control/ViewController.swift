//
//  ViewController.swift
//  home control
//
//  Created by Atharva Patil on 06/04/2019.
//  Copyright © 2019 Atharva Patil. All rights reserved.
//


//Importing the UI kit for asset development & Speech for speech detection
//Importing Siri Wave form View module
import UIKit
import Speech
import SwiftSiriWaveformView
import Haptica
import Peep


class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    
    
    var timer: Timer?
    var change: CGFloat = 0.01
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var recorder: AVAudioRecorder!

    @IBOutlet weak var hapticResponder: UIButton!{
        didSet {
            hapticResponder.addHaptic(.impact(.heavy), forControlEvents: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var audioWaveView: SwiftSiriWaveformView!
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    
    
    var mostRecentlyProcessedSegmentDuration: TimeInterval = 0
    
    var lastBestString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.requestSpeechAuthorization()
        
        self.audioWaveView.density = 1.0
        self.audioWaveView.waveColor = UIColor.blue
        
        if self.recorder != nil {
            return
        }
        
        let url: NSURL = NSURL(fileURLWithPath: "/dev/null")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.recorder = try AVAudioRecorder(url: url as URL, settings: settings )
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)))
            
            self.recorder.record()
            
            timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(refreshAudioView(_:)), userInfo: nil, repeats: true)
        } catch {
            print("Fail to record.")
        }
        
//        colourView.backgroundColor = .green
    }
    
    @IBAction func hapticTouch(_ sender: UIButton) {
         Peep.play(sound: AlertTone.tweet)
    }
    
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("authorized")
                    self.recordAndRecognizeSpeech()
                case .denied:
                    print("denied")
                case .restricted:
                    print("restricted")
                case .notDetermined:
                    print("notDetermined")
                @unknown default:
                    return
                }
            }
        }
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                
                if let lastSegment = result.bestTranscription.segments.last,
                    lastSegment.duration > self.mostRecentlyProcessedSegmentDuration {
                    self.mostRecentlyProcessedSegmentDuration = lastSegment.duration
                    
                    /////////////////////////////////////////////////////////////////////
                    // Get last spoken word.
                    // Process request here.
                    
                    let string = lastSegment.substring
                    
                    if string.lowercased() == "eat" {
                        self.view.backgroundColor = .green
                    } else if string.lowercased() == "be" {
                        Haptic.play("..oO-Oo..", delay: 0.1)
                        self.view.backgroundColor = .red
                    } else if string.lowercased() == "black" {
                        self.view.backgroundColor = .black
                    }
                    
                    /////////////////////////////////////////////////////////////////////
                }
                
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
            
        })
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc internal func refreshAudioView(_: Timer) {
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.audioWaveView.amplitude = 0.7
        
        recorder.updateMeters()
        
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePower(forChannel: 0))/20)
        self.audioWaveView.amplitude = normalizedValue
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

    
//    @IBAction func toggleTapped(_ sender: Any) {
//
//        if(toggleState == false){
//            colourView.backgroundColor = .red
//            toggleState = true
//        } else if(toggleState == true){
//            colourView.backgroundColor = .blue
//            toggleState = false
//        }
//
//    }
