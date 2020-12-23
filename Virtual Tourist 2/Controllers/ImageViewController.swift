//
//  ImageViewController.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 06/12/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import RealmSwift

protocol SendControlIdDelegate {
    func sendId(controlId: String)
}

class ImageViewController: UIViewController {
    //MARK:- Variables
    var delegate: SendControlIdDelegate?
    var imageString: String?
    var imageLocation: Pins?
    var imageResults: List<Images>?
    var selectedIndex: Int?
    var currentImage:Int = 0
    let controlId = "imageViewController"

    //MARK:- UI Component variables
    var backButton: UIButton = {
        let button = UIButton()
        let color = UIColor(displayP3Red: 61/255, green: 167/255, blue: 244/255, alpha: 0.9)
        button.styleButton(imageName: "arrow.left", bodyColor: color, iconColor: .white)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.styleButton(imageName: "bin.xmark", bodyColor: UIColor.red.withAlphaComponent(0.8), iconColor: .white)
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let locationImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .black
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    //MARK:- Main Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    fileprivate func setup() {
        view.backgroundColor = .white
        if ((imageLocation?.imageUrls.count)!) > 0 {
            imageResults = imageLocation?.imageUrls
        }
        currentImage = selectedIndex!
        setupView()
        displayImage(imageString: imageString!)
        addLeftRightGestureForImage()
    }
    
    //MARK:- Methods to Display a Picture
    func displayImage(imageString: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(imageString)
        locationImage.image = UIImage(contentsOfFile: imagePath.path)
    }
    
    //MARK:- Methods to Delete a Picture
    fileprivate func deleteImage(_ theImage: Images) {
        do {
            try RealmHelper.realm.write {
                RealmHelper.realm.delete(theImage)
                self.delegate?.sendId(controlId: self.controlId)
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print("Error deleting image, \(error)")
        }
        
        if let pin = self.imageLocation {
            do {
                try RealmHelper.realm.write {
                    pin.numberOfUrls = pin.numberOfUrls - 1
                }
            } catch {
                print("Error decrementing imageUrls count, \(error)")
            }
        }
    }
    
    @objc private func deleteButtonPressed() {
        let deleteAlert = UIAlertController(title: "Confirm delete?", message: "Image will be deleted", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            if let theImage = self.imageResults?[self.currentImage] {
                self.deleteImage(theImage)
            }
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    //MARK:- Method for Back Button
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    //MARK:- Methods for Swiping Left/Right to View Images
    func addLeftRightGestureForImage() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .left:
                if currentImage == imageResults!.count - 1 {
                    currentImage = 0
                } else {
                    currentImage = currentImage + 1
                }
                displayImage(imageString: imageResults![currentImage].directoryURLOFSavedImage)
                
            case .right:
                if currentImage == 0 {
                    currentImage = imageResults!.count - 1
                } else {
                    currentImage = currentImage - 1
                }
                displayImage(imageString: imageResults![currentImage].directoryURLOFSavedImage)
            default:
                break
            }
        }
    }
    
    //MARK:- Method to Setup View
    func setupView() {
        view.addSubview(locationImage)
        NSLayoutConstraint.activate([
            locationImage.topAnchor.constraint(equalTo: view.topAnchor),
            locationImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.heightAnchor.constraint(equalToConstant: 35),
            backButton.widthAnchor.constraint(equalToConstant: 35),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0)
        ])
        
        view.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 35),
            deleteButton.widthAnchor.constraint(equalToConstant: 35),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            deleteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0)
        ])
    }
}
