//
//  ViewController.swift
//  CanCam
//
//  Created by Tanner Luke on 8/10/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import CoreMotion

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var amountOfPicturesLabel: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountDoneButton: UIButton!
    @IBOutlet weak var doneAmountView: UIView!
    @IBOutlet weak var timeAmountView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var timeDoneButton: UIButton!
    @IBOutlet weak var timeDoneView: UIView!
    @IBOutlet weak var timeDoneLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var toPicCollectionButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var numberOfPixButton: UIButton!
    
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var amountToTake: Int?
    var durationOfTime: Int? = 15
    var currentPicRow: Int?
    var currentTimeRow: Int?
    var isScreenDark: Bool = false
    var previousAverage: Double = 0
    
    //CORE MOTION
    var motionManager: CMMotionManager!
    var valueX: Double!
    var valueY: Double!
    var valueZ: Double!
    var totalX: Double = 0
    var totalY: Double = 0
    var totalZ: Double = 0
    
    var originalBrightness: CGFloat!
    var isMovingX: Bool!
    var isMovingY: Bool!
    
    var accelArrayX = [Double]()
    var accelArrayY = [Double]()
    var accelArrayZ = [Double]()
    
    
    
    //USER INTERFACE
    
    var takePicture = UIButton()
    var toNextScreen = UIButton()
    var changeAmount = UIButton()
    let blackView = UIView()
    var photosTakenArray = [Data]()
    var timer: Timer = Timer()
    var seconds: Int = 0
    var stopTime: Int?
    var timeBetween: Int = 0
    var numberArray = [Int]()
    var times = [Int](1...150)
    var minutes = [Int](1...59)
    var longTimes = ["1 Hour", "1 Hour 15 Minutes", "1 Hour 30 Minutes", "1 Hour 45 Minutes", "2 Hours"]
    var allTimes = [String]()
    var yPoint: CGFloat!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        yPoint = (self.view.frame.size.height - (self.view.frame.size.width * 1.333333)) * 0.442176870748299
        
        

        motionManager = CMMotionManager()
        
        originalBrightness = UIScreen.main.brightness
        
        allTimes = convertToString(array: minutes)
        
        timePicker.tag = 0
        timePickerView.tag = 1
        timePickerView.delegate = self
        timePicker.delegate = self
        timePickerView.dataSource = self
        timePicker.dataSource = self
        
        timePicker.selectRow(14, inComponent: 0, animated: false)
        timePickerView.selectRow(14, inComponent: 0, animated: false)
        
        amountToTake = 15
        durationOfTime = 15
        stopTime = durationOfTime
        alignment()
        loadCamera()
        
        isMovingX = false
        isMovingY = false
        
        self.view.backgroundColor = .lightGray
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if paused == true {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(add), userInfo: nil, repeats: true)
            paused = false
        }
    }
    
    func convertToString(array: [Int]) -> [String] {
        
        let arr = array
        
        var stringArray = [String]()
        
        for item in arr {
            let str = String(item)
            stringArray.append(str)
        }
        
        for hour in longTimes {
            stringArray.append(hour)
        }
        
        return stringArray
    }
    
    
    
    func alignment() {
        //PICKERVIEW FOR AMOUNT OF PICTURES
        amountView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
        doneAmountView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60)
        amountView.addSubview(doneAmountView)
        amountDoneButton.frame = CGRect(x: self.view.frame.size.width - 65, y: self.doneAmountView.frame.size.height / 2 -  15, width: 50, height: 30)
        doneAmountView.addSubview(amountDoneButton)
        amountOfPicturesLabel.frame = CGRect(x: self.doneAmountView.frame.size.width / 2 - 100, y: self.doneAmountView.frame.size.height / 2 - 10, width: 200, height: 20)
        amountOfPicturesLabel.textAlignment = .center
        doneAmountView.addSubview(amountOfPicturesLabel)
        
        //PICKERVIEW FOR AMOUNT OF TIME
        timeAmountView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
        timeDoneView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 60)
        timeAmountView.addSubview(timeDoneView)
        timeDoneButton.frame = CGRect(x: self.view.frame.size.width - 65, y: self.doneAmountView.frame.size.height / 2 -  15, width: 50, height: 30)
        timeDoneView.addSubview(timeDoneButton)
        timeDoneLabel.frame = CGRect(x: self.doneAmountView.frame.size.width / 2 - 100, y: self.doneAmountView.frame.size.height / 2 - 10, width: 200, height: 20)
        timeDoneLabel.textAlignment = .center
        timeDoneView.addSubview(timeDoneLabel)
        
        
        
        //CAMERA VIEW ALIGNMENT
        let topView = UIView()
        topView.backgroundColor = UIColor(red: 76/255, green: 84/255, blue: 108/255, alpha: 1)
        topView.frame = CGRect(x: 0, y: 0, width:
            self.view.frame.size.width, height: yPoint)
        self.view.addSubview(topView)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(red: 76/255, green: 84/255, blue: 108/255, alpha: 1)
        let height = self.view.frame.size.height - (yPoint + (self.view.frame.size.width * 1.333333))
        bottomView.frame = CGRect(x: 0, y: yPoint + (self.view.frame.size.width * 1.333333), width: self.view.frame.size.width, height: height)
        self.view.addSubview(bottomView)
        
        toPicCollectionButton.backgroundColor = UIColor.clear
        toPicCollectionButton.frame = CGRect(x: self.view.frame.size.width - 60, y: (topView.frame.size.height/2 - 30) + UIApplication.shared.statusBarFrame.height, width: 40, height: 40)
        topView.addSubview(toPicCollectionButton)
        
        restartButton.backgroundColor = UIColor.clear
        restartButton.frame = CGRect(x: 20, y: (topView.frame.size.height/2 - 30) + UIApplication.shared.statusBarFrame.height, width: 40, height: 40)
        topView.addSubview(restartButton)
        
        
        numberOfPixButton.frame = CGRect(x: self.view.frame.size.width - 70, y: bottomView.frame.size.height / 2 - 20, width: 40, height: 40)
        bottomView.addSubview(numberOfPixButton)
        
   
        durationButton.frame = CGRect(x: 30, y: bottomView.frame.size.height / 2 - 20, width: 40, height: 40)
        bottomView.addSubview(durationButton)
        
        captureButton.backgroundColor = UIColor.groupTableViewBackground
        captureButton.frame = CGRect(x: bottomView.frame.size.width/2 - 30 , y: bottomView.frame.size.height / 2 - 30, width: 60, height: 60)
        captureButton.layer.cornerRadius = 30
        captureButton.setTitle("", for: .normal)
        bottomView.addSubview(captureButton)
        
        let circle = UIBezierPath(arcCenter: CGPoint(x: captureButton.frame.size.width/2, y: captureButton.frame.size.height / 2), radius: 27, startAngle: CGFloat(0), endAngle: CGFloat.pi * 2, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circle.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor(red: 76/255, green: 84/255, blue: 108/255, alpha: 1).cgColor
        captureButton.layer.addSublayer(shapeLayer)
        
        
        
        
        self.view.bringSubviewToFront(timeAmountView)
        self.view.bringSubviewToFront(amountView)
        
        
    }
    
    func runTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(add), userInfo: nil, repeats: true)
        
    }
    
    @objc func add() {
        
        print(seconds)
        if let accelerometerData = motionManager.accelerometerData {
            
            valueX = accelerometerData.acceleration.x
            valueY = accelerometerData.acceleration.y
            valueZ = accelerometerData.acceleration.z
            
        }
        
        if valueX != nil {
            accelArrayX.append(valueX)
        }
        
        if valueY != nil {
            accelArrayY.append(valueY)
        }
        
        if valueZ != nil {
            accelArrayZ.append(valueZ)
        }
        
        if accelArrayY.count > 5 {
            
            let average: Double!
            let tempArray = accelArrayY.suffix(6)
            
            for y in tempArray.dropLast() {
                totalY += y
            }
            
            average = totalY / 5.0
            let lastVal: Double?
            lastVal = accelArrayY.last
            let diff = average - lastVal!
            let absDiff = abs(diff)
            
            if absDiff > 0.05 {
                isMovingY = true
            } else if absDiff > 0.01 {
                wake()
                timeBetween = 0
            } else if timeBetween > 5 {
                dim()
            }
            totalY = 0
        }
        
        if accelArrayX.count > 5 {
            let average: Double!
            let tempArray = accelArrayX.suffix(6)
            
            for x in tempArray.dropLast() {
                totalX += x
            }
            
            average = totalX / 5.0
            let lastVal: Double!
            lastVal = accelArrayX.last
            let diff = average - lastVal!
            let absDif = abs(diff)
            
            if absDif > 0.05 {
                isMovingX = true
            } else if absDif > 0.0085 {
                wake()
                timeBetween = 0
            } else if timeBetween > 5 {
                dim()
            }
            totalX = 0
        }
        
        
        if isMovingX == true && isMovingY == true && isScreenDark == true {
            AudioServicesPlayAlertSound(1304)
        }
        

        if numberArray.contains(seconds) {
            capturePicture()
        }
        
        if seconds == stopTime {
            timer.invalidate()
        }
        
        seconds += 1
        timeBetween += 1
        
    }
    
    func loadCamera() {
        setupDevice()
        setupCaptureSession()
        setupInputOutput()
        setupPreviewLayer()
        startCaptureRunningCaptureSession()
        
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    
    func setupDevice() {
        let deviceDiscoveryStation = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoveryStation.devices
        
        for device in devices {
            if device.position == .back {
                backCamera = device
                
            } else if device.position == .front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = CGRect(x: 0, y: yPoint, width: self.view.frame.size.width, height: self.view.frame.size.width * 1.33333)
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func startCaptureRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @objc func capturePicture() {
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    
    @objc func wake() {
        UIScreen.main.brightness = originalBrightness
        blackView.removeFromSuperview()
        isScreenDark = false
    }
    
    func dim() {
        blackView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        blackView.backgroundColor = .black
        self.view.addSubview(blackView)
        
        UIScreen.main.brightness = 0
        isScreenDark = true
    }
    
    func getRandomNumberArray() -> [Int] {
        
        var randomArray = [Int]()
        var i = 0
        
        
        stopTime = durationOfTime! * 60
        
        
        if amountToTake! > stopTime! {
            amountToTake = stopTime
        }
        
        while (i < amountToTake!) {
            
            let ran = Int.random(in: 0..<stopTime!)
            if randomArray.contains(ran) == false {
                randomArray.append(ran)
                i+=1
            } 
        }
        print("ran")
        return randomArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPicArray" {
            print("running")
            timer.invalidate()
            paused = true
            let vc = segue.destination as! UINavigationController
            let arrayVC = vc.topViewController as! PhotosTakenVC
            
            arrayVC.dataArray = photosTakenArray
        }
    }
    
    @IBAction func forwardClick(_ sender: Any) {
        self.performSegue(withIdentifier: "toPicArray", sender: self)
        
    }
    
    @IBAction func durationClick(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.timeAmountView.frame = CGRect(x: 0, y: self.view.frame.size.height - 270, width: self.view.frame.size.width, height: 270)
        }
    }
    
    @IBAction func numberOfPicsClick(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.amountView.frame = CGRect(x: 0, y: self.view.frame.size.height - 270, width: self.view.frame.size.width, height: 270)
        }
    }
    
    @IBAction func amountDoneClick(_ sender: Any) {
        dismissAmountPicker()
    }
    
    @IBAction func timeDoneClick(_ sender: Any) {
       dismissMinutePicker()
    }
    
    func dismissAmountPicker() {
        timePicker.selectRow(currentPicRow!, inComponent: 0, animated: false)
        amountToTake = times[currentPicRow!]
        UIView.animate(withDuration: 0.4) {
            self.amountView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
       
    }
    
    func dismissMinutePicker() {
        timePickerView.selectRow(currentTimeRow!, inComponent: 0, animated: false)
        let str = allTimes[currentTimeRow!]
        switch str {
        
            case "1 Hour":
                durationOfTime = 60
            
            case "1 Hour 15 Minutes":
                durationOfTime = 75
            
            case "1 Hour 30 Minutes":
                durationOfTime = 90
            
            case "1 Hour 45 Minutes":
                durationOfTime = 105
            
            case "2 Hours":
                durationOfTime = 120
            
            default:
                durationOfTime = Int(allTimes[currentTimeRow!])
            }
        
        UIView.animate(withDuration: 0.4) {
            self.timeAmountView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        
        
    }
    
    @IBAction func capture(_ sender: Any) {
        print("hello")
        numberArray = getRandomNumberArray()
        print(numberArray)
        runTimer()
        motionManager.startAccelerometerUpdates()
    }
    
    @IBAction func restartClick(_ sender: Any) {
      
        
        
        let alert = UIAlertController(title: "Restart Session?", message: "This will clear all pictures and data. Images taken will not be able to be recovered. Are you sure you want to proceed?", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Clear", style: .default) { (UIAlertAction) in
            self.photosTakenArray.removeAll(keepingCapacity: false)
            NotificationCenter.default.post(name: NSNotification.Name("clear"), object: nil)
            self.timer.invalidate()
            self.seconds = 0
        }
        alert.addAction(action)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}


extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            
            photosTakenArray.append(imageData)
            //guard let image = UIImage(data: imageData) else {return}
            //photosTakenArray.append(image)
            
            
        }
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
        
            return times.count
        }
        
        else {
            return allTimes.count
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            
            currentPicRow = row
            return "\(times[row])"
            
        }
        else {
           
            currentTimeRow = row
            return "\(allTimes[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            
            amountToTake = times[row]
            
        } else {
            
            if allTimes[row] == "1 Hour" {
                
                durationOfTime = 60
                
            } else if allTimes[row] == "1 Hour 15 Minutes" {
                
                durationOfTime = 75
                
            } else if allTimes[row] == "1 Hour 30 Minutes" {
                
                durationOfTime = 90
                
            } else if allTimes[row] == "1 Hour 45 Minutes" {
                
                durationOfTime = 105
                
            } else if allTimes[row] == "2 Hours" {
                
                durationOfTime = 120
                
            } else {
                
                durationOfTime = Int(allTimes[row])
                
            }
            
            
            
            
        }
        
    }
    
}

