//
//  PlaySoundViewController.swift
//  PitchPerfect
//
//  Created by Klaus Villaca on 5/12/15.
//  Copyright (c) 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import AVFoundation


class PlaySoundViewController: UIViewController {
    
    // Background color
    let lightBlue: UInt32 = 0x74A7FA
    
    // Declare IBOutlet for all buttons that will need to have disable/enable
    @IBOutlet weak var playSlowButton: UIButton!
    @IBOutlet weak var playFastButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var darthVaderButton: UIButton!
    @IBOutlet weak var playView: UIView!
    
    // Declare variables
    var audioFile : AVAudioFile?
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var error : NSError?
    var colorUtil: Util!
    
    
    // Declare variable that will receive the segue values
    var recordedAudioToPlay: RecordedAudio!
    
    
    // Declare an enum, to avoid work with Strings or numbers
    enum PitchOrRate {
        case rate, pitch
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorUtil = Util()
        
        // Set the background color is a better option for speed and memory consuption than use a file for background.
        self.playView.backgroundColor = colorUtil.UIColorFromHex(lightBlue, alpha: 0.9)
        
        // Initialize the audioEngine and audioFile
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: recordedAudioToPlay.filePathUrl, error: &error)
        
        // If something goes wrong when initializing audioFile, we can get the error
        if let e = error {
            alert(e.localizedDescription, titleStr: "Error")
//            println(e.localizedDescription)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Acion called when tap the snail button
    @IBAction func playSlowAction(sender: UIButton) {
        playSlowButton.enabled = false
        playFastButton.enabled = true
        chipmunkButton.enabled = true
        darthVaderButton.enabled = true
        playSound(0.5, typeForAudio: PitchOrRate.rate)
    }
    
    
    // Acion called when tap the snail button
    @IBAction func playFastACtion(sender: UIButton) {
        playSlowButton.enabled = true
        playFastButton.enabled = false
        chipmunkButton.enabled = true
        darthVaderButton.enabled = true
        playSound(2.0, typeForAudio: PitchOrRate.rate)
    }
    
    
    // Acion called when tap the chipmunk button
    @IBAction func chipmunkAction(sender: UIButton) {
        playFastButton.enabled = true
        playSlowButton.enabled = true
        chipmunkButton.enabled = false
        darthVaderButton.enabled = true
        playSound(1000, typeForAudio: PitchOrRate.pitch)
    }
    
    
    // Acion called when tap the darth vader button
    @IBAction func darthVaderAction(sender: UIButton) {
        playFastButton.enabled = true
        playSlowButton.enabled = true
        chipmunkButton.enabled = true
        darthVaderButton.enabled = false
        playSound(-1000, typeForAudio: PitchOrRate.pitch)
    }
    
    
    // Acion called when tap the stop button
    @IBAction func stopPlayAction(sender: UIButton ) {
        enableAllButtons()
        if let isStillWorking = audioPlayerNode {
            isStillWorking.stop()
            isStillWorking.stop()
            isStillWorking.reset()
        }
    }
    
    
    // Common function to play sounds
    func playSound(valueForAudioType: Float, typeForAudio: PitchOrRate) {
        audioPlayerNode = AVAudioPlayerNode()
        
        audioPlayerNode!.stop()
        audioEngine!.stop()
        audioEngine!.reset()
        
        audioEngine!.attachNode(audioPlayerNode)
        
        var changeAudioUnitTime = AVAudioUnitTimePitch()
        
        switch typeForAudio {
        case .pitch:
            changeAudioUnitTime.pitch = valueForAudioType
            
        case .rate:
            changeAudioUnitTime.rate = valueForAudioType
        }
        
        audioEngine!.attachNode(changeAudioUnitTime)
        audioEngine!.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
        audioEngine!.connect(changeAudioUnitTime, to: audioEngine!.outputNode, format: nil)
        audioPlayerNode!.scheduleFile(audioFile, atTime: nil, completionHandler: {self.enableAllButtons()})
        audioEngine!.startAndReturnError(&error)
        if let e = error {
            alert(e.localizedDescription, titleStr: "Error")
//            println(e.localizedDescription)
        }
        
        audioPlayerNode!.play()
    }
    
    
    // Function to enable all buttons
    func enableAllButtons() {
        playSlowButton.enabled = true
        playFastButton.enabled = true
        chipmunkButton.enabled = true
        darthVaderButton.enabled = true
    }
    
    
    // Function to allert the user.
    func alert(messageStr: String, titleStr: String) {
        var alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Remove the file that will no be used anymore with this app structure
    override func viewWillDisappear(animated: Bool) {
        let filemgr = NSFileManager.defaultManager()
        if filemgr.removeItemAtURL(recordedAudioToPlay.filePathUrl, error: &error) {
            println("Remove successful")
        } else {
            println("Remove failed: \(error!.localizedDescription)")
        }
    }
}
