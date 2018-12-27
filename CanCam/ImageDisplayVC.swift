//
//  ImageDisplayVC.swift
//  CanCam
//
//  Created by Tanner Luke on 10/8/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import UIKit

var AppImageArray = [UIImage]()
var SelectedIndexesGlobal = [Int]()
var paused = false

class ImageDisplayVC: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomButtonView: UIView!
    var selectedIndexes = [Int]()
    var isHidden = false
    var startingImage: UIImage?
    var startingIndex: Int?
    
    var imageView1: UIImageView?
    
    var width: CGFloat?
    
    var bottomConstraint: NSLayoutConstraint?
    
    var zooming = false
    var images = [UIImage]()
    var imageViewArray = [UIImageView]()
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var currentIndex = 0
    
    var buttonViewFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alwaysBounceVertical = false
        navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backButton))
        
        images = AppImageArray
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.isPagingEnabled = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        
        loadImages()
        
        setupBottomConstraints()
        
        width = self.view.frame.size.width
        
        print(images)
        print("Starting index is ", startingIndex!)
        
        let point = CGPoint(x: (self.view.frame.size.width) * CGFloat(startingIndex!), y: 0)
        currentIndex = startingIndex!
        
        scrollView.setContentOffset(point, animated: false)
        view.backgroundColor = .black
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(hideTap))
        tapToHide.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapToHide)
        buttonViewFrame = bottomButtonView.frame
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //self.selectedIndexes.removeAll(keepingCapacity: false)
        //self.images.removeAll(keepingCapacity: false)
    }
    
    @objc func hideTap() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isHidden == false {
            bottomConstraint?.isActive = false
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            UIView.animate(withDuration: 0.19) {
                self.bottomConstraint = self.bottomButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 150)
                self.bottomConstraint?.isActive = true
                self.bottomButtonView.frame.origin.y = (self.buttonViewFrame?.origin.y)! + 200
            }
            
            self.isHidden = true
        } else {
            
            bottomConstraint?.isActive = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            UIView.animate(withDuration: 0.19) {
                self.bottomConstraint = self.bottomButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                self.bottomConstraint?.isActive = true
                self.bottomButtonView.frame.origin.y = (self.buttonViewFrame?.origin.y)!

            }
            
            self.isHidden = false
        }
    }
    
    
    
    func loadImages() {
        
        
        /*
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor)
            
            ].forEach{$0.isActive = true}
        
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [
        
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height - 60)
        
            ].forEach { $0.isActive = true }
        */
        for i in 0..<images.count {
            
            
            let scrollViews = UIScrollView()
            let x = (self.view.frame.size.width) * CGFloat(i)
            scrollViews.frame = CGRect(x: x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)//self.view.frame.size.width * 1.3333)
            
            
            
            
            scrollViews.alwaysBounceHorizontal = false
            scrollViews.alwaysBounceVertical = false
            
            
            let imageView = UIImageView()
            //let x = (self.view.frame.size.width) * CGFloat(i)
            imageView.frame = scrollViews.frame
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[i]
            
            let contentHeight = self.view.frame.size.width * 1.3333
           
            contentView.frame = CGRect(x: 0, y: ((self.view.frame.size.height - 60) / 2) - (contentHeight / 2) + 30, width: (imageView.frame.size.width) * CGFloat(images.count), height: contentHeight)
            //contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
            
            
            //scrollView.contentSize.width = imageView.frame.size.width * CGFloat(images.count)//(scrollView.frame.size.width * CGFloat(images.count))
            scrollView.contentSize.width = contentView.frame.size.width
            //scrollView.addSubview(imageView)
            //contentView.frame.size.width = imageView.frame.size.width * CGFloat(images.count)
            scrollViews.addSubview(imageView)
            contentView.addSubview(scrollViews)
            imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width * 1.33333)
            
            
            
            //contentView.addSubview(imageView)
            
       
            
        }
        
    }
    /*
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: currentIndex - 20, y: 0)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let index: Int = Int(contentOffset.x / imageViewArray[0].frame.size.width)
        
        currentIndex = index
        print(currentIndex)
    }
    */
    
    func setupBottomConstraints() {
        bottomButtonView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = bottomButtonView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint?.isActive = true
        [
            bottomButtonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 60),
            
            
            saveButton.topAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: bottomButtonView.leadingAnchor, constant: 15),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.widthAnchor.constraint(equalToConstant: 60),
            
            selectButton.topAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 10),
            selectButton.trailingAnchor.constraint(equalTo: bottomButtonView.trailingAnchor, constant: -15),
            selectButton.heightAnchor.constraint(equalToConstant: 40),
            selectButton.widthAnchor.constraint(equalToConstant: 60),
            
            
            
            ].forEach {$0.isActive = true}
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func backButton() {
        
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if zooming == false {
            let contentOffset = scrollView.contentOffset
            print(contentOffset)
            //let index: Int = Int(contentOffset.x / imageViewArray[0].frame.size.width)
        
            //currentIndex = index
            print(currentIndex)
            
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return contentView //imageViewArray[currentIndex]
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zooming = true
        
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        //let point = CGPoint(x: width! * CGFloat(currentIndex), y: 0)
        //scrollView.setContentOffset(point, animated: true)
        
        scrollView.setZoomScale(1.0, animated: true)
        
        
        
    }
    
    
    @IBAction func selectButtonClick(_ sender: Any) {
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
