//
//  PhotosTakenVC.swift
//  CanCam
//
//  Created by Tanner Luke on 8/10/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import UIKit


class PhotosTakenVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dataArray = [Data]()
    var selectMode: Bool!
    var selectedArray = [Bool]()
    var selectedIndexes = [Int]()
    var imageArray = [UIImage]()
    
    var zoomInOn: Int?
    var zoomInOnImage: UIImage?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backToCameraButton: UIBarButtonItem!
    
    let highlightColor = UIColor(displayP3Red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        createSelectedArray()
        selectMode = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotosTakenVC.clearArrays), name: NSNotification.Name(rawValue: "clear"), object: nil)
        
        saveButton.title = "Select"
        backToCameraButton.title = "Back"
        backToCameraButton.tag = 0
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 76/255, green: 84/255, blue: 108/255, alpha: 1)
        self.collectionView.backgroundColor = .lightGray
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: self)
        
        if segue.identifier == "closeUp" {
            let vc1 = segue.destination as! UINavigationController
            let vc = vc1.topViewController as! ImageDisplayVC
            //vc.images = imageArray
            AppImageArray = imageArray
            vc.startingImage = zoomInOnImage
            vc.startingIndex = zoomInOn
        }
        
    }
    
    

  
    @IBAction func backButtonClicked(_ sender: Any) {
        
        if backToCameraButton.tag == 0 {
            dataArray.removeAll(keepingCapacity: false)
            selectedArray.removeAll(keepingCapacity: false)
            selectedIndexes.removeAll(keepingCapacity: false)
            imageArray.removeAll(keepingCapacity: false)
            self.dismiss(animated: true, completion: nil)
        } else if backToCameraButton.tag == 1 {
            selectMode = false
            for index in selectedIndexes {
                let indexPath = IndexPath(row: index, section: 0)
                let cell = collectionView.cellForItem(at: indexPath)
                cell?.layer.borderWidth = 0
            }
            selectedIndexes.removeAll(keepingCapacity: false)
            selectedArray.removeAll(keepingCapacity: false)
            createSelectedArray()
            backToCameraButton.tag = 0
            saveButton.title = "Select"
        }
        
        
        
        
        
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        
        
        if saveButton.title == "Select" {
            selectMode = true
            saveButton.title = "Save"
            navigationController?.navigationBar.barTintColor = UIColor(red: 76/255, green: 84/255, blue: 108/255, alpha: 1)
            backToCameraButton.tag = 1
        } else if saveButton.title == "Save" {
            
            savePictures()
            saveButton.title = "Select"
            backToCameraButton.tag = 0
            navigationController?.navigationBar.barTintColor = UIColor.white
            
        }
        
       
        
        
    }
    
    @objc func clearArrays() {
        print("clearing")
        dataArray.removeAll(keepingCapacity: false)
        selectedIndexes.removeAll(keepingCapacity: false)
        selectedArray.removeAll(keepingCapacity: false)
        imageArray.removeAll(keepingCapacity: false)
    }
    
    func createSelectedArray() {
        let count = dataArray.count
        var i = 0
        while i < count {
            selectedArray.append(false)
            i+=1
        }
    }
    
    

 


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of item
        return dataArray.count
    }
    


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
    
        
        let picture = UIImage(data: dataArray[indexPath.row])
        
        imageArray.append(picture!)
        
        cell.photo.image = picture
        // Configure the cell
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/4 - 1, height: self.view.frame.size.width/4
            - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectMode == true {
            let cell = collectionView.cellForItem(at: indexPath)
            if selectedArray[indexPath.row] == false {
                
                selectedArray[indexPath.row] = true
                cell?.layer.borderWidth = 2
                cell?.layer.borderColor = highlightColor.cgColor
                
                selectedIndexes.append(indexPath.row)
                
                
            
            } else {
                cell?.layer.borderWidth = 0
                selectedArray[indexPath.row] = false
                if let index = selectedIndexes.index(of: indexPath.row) {
                    selectedIndexes.remove(at: index)
                }
                
            }
        } else {
            
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
            
            self.zoomInOn = indexPath.row
            self.zoomInOnImage = cell.photo.image
            
            SelectedIndexesGlobal = selectedIndexes
            
            self.performSegue(withIdentifier: "closeUp", sender: self)
            
        }
        
        
        
    }
    
    
    
    
    
    func savePictures() {
        
        selectedIndexes.sort()
        print(selectedIndexes)
        
        var i = 0
        
        while i < selectedIndexes.count {
            
            if imageArray.isEmpty == false {
            
                let indexOfImage = selectedIndexes[i]
                
                let imageToSave = imageArray[indexOfImage]
                UIImageWriteToSavedPhotosAlbum(imageToSave, self, nil, nil)
            
            }
            
            i+=1
        }
        
        
    }
    
    

    

}
