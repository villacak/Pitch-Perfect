//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Klaus Villaca on 5/8/15.
//  Copyright (c) 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioSessionDelegate {
    
    // Static segue name, to avoid have duplicated strings across the code.
    let recordSegueName: String = "stopRecordingToPlaySegue"
    let threeSeconds: Double = 3.0
    
    // Background colors
    let lightBlue: UInt32 = 0x74A7FA
    let slightRed: UInt32 = 0xFC4E54
    
    
    // Declare IBOutlet for all buttons that will need to have disable/enable
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var labelTip: UILabel!
    
    // Declare variables
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var session: AVAudioSession!
    var colorUtil: Util!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorUtil = Util()
        
        // Set the background color
        self.recordingView.backgroundColor = colorUtil.UIColorFromHex(lightBlue, alpha: 0.9)
        
        // Initialise vars to create the file name
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        
        // Initialize the NSURL with the file path and file name
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        session = AVAudioSession.sharedInstance()
        
        // Set session for Record to avoid recording very quiet sounds
        session.setCategory(AVAudioSessionCategoryRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        
        
        // Hide the label after 3 seconds
        colorUtil.delay(threeSeconds) {
            self.labelTip.hidden = true
        }
        
    }
    
    
    // We could have avoid this method if set the stopButton as hidden in the storyboard.
    override func viewWillAppear(animated: Bool) {
        self.stopButton.hidden = true
    }
    
    
    // Action called when tap record audio button - Microphone
    @IBAction func recordAudio(sender: UIButton) {
        self.recordingLabel.hidden = false
        self.stopButton.hidden = false
        self.recordingButton.enabled = false
        
        self.recordingView.backgroundColor = colorUtil.UIColorFromHex(slightRed, alpha: 0.9)
        
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    // Action called when tap stop button
    @IBAction func stopRecording(sender: UIButton) {
        stopRecodingButtonsSettings()
        revertCategoryToPlayBack()
    }
    
    
    // Delegate the check if the recording has finished and if success or fail
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            // This is necessary to have the play with audible audio
            revertCategoryToPlayBack()
            
            recordedAudio = RecordedAudio()
            recordedAudio.filePathUrl = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            self.performSegueWithIdentifier(recordSegueName, sender: recordedAudio)
        } else {
            var alert = UIAlertController(title: "Recording Failed", message: "Recording audio has finished with problem. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            stopRecodingButtonsSettings()
        }
    }
    
    
    
    // Prepare for segue, transfer data to the next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == recordSegueName) {
            let playSoundsViewController: PlaySoundViewController = segue.destinationViewController as! PlaySoundViewController
            let data = sender as! RecordedAudio
            playSoundsViewController.recordedAudioToPlay = data
        }
    }
    
    
    // Enallbe all button when stop.
    func stopRecodingButtonsSettings() {
        self.recordingLabel.hidden = true
        self.stopButton.hidden = true
        self.recordingButton.enabled = true
    }
    
    
    // Revert the category to playback
    func revertCategoryToPlayBack() {
        audioRecorder.stop()
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        session.setActive(false, error: nil)
        self.recordingView.backgroundColor = colorUtil.UIColorFromHex(lightBlue, alpha: 0.9)
    }
}

