//
//  MapImagesViewController.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 28/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import MBProgressHUD

typealias ImageCount = Int
typealias ListOfImages = List<Images>

class ImageAlbumController: UIViewController {
    
    //MARK:- UI Component variables
    var mapViewContainer: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var mapView: MKMapView = {
        var map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
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
    
    var refreshButton: UIButton = {
        let button = UIButton()
        let color = UIColor(displayP3Red: 39/255, green: 216/255, blue: 39/255, alpha: 0.9)
        button.styleButton(imageName: "arrow.clockwise", bodyColor: color, iconColor: .white)
        button.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let hintView: UIView = {
        let view = UIView()
        view.backgroundColor = lightBlueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let showViewText: UILabel = {
        let label = UILabel()
        label.text = "Fetching pictures, please wait..."
        label.textColor = .white
        label.font = UIFont(name: "Avenir-Heavy", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let maxImages = 42
    let collectionCellId = "cellId"
    var sentControlId: String?
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var locationSearchString: String {
        return "\(locationAnnotation?.annotation?.coordinate.latitude ?? 0.0)" + "\(locationAnnotation?.annotation?.coordinate.longitude ?? 0.0)"
    }
    var location: Pins?
    var locationAnnotation: MKAnnotationView?
    var imageResults: List<Images>?
    var countOfImages: ImageCount? {
        didSet {
            setUpInitialCollectionView()
        }
    }
    
    //MARK:- Main Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar()
        setupView()
        hintView.isHidden = true
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: collectionCellId)
        
        if let annotationData = locationAnnotation {
            let latitude = annotationData.annotation?.coordinate.latitude
            let longitude = annotationData.annotation?.coordinate.longitude
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(mapRegion, animated: true)
            mapView.addAnnotation(annotationData.annotation!)
        }
        
        if (location?.imageUrls.count)! > 0 {
            imageResults = location?.imageUrls
            countOfImages = imageResults?.count
        } else {
            initiateImageRequests()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let controller = sentControlId {
            if controller == "imageViewController" {
                imageResults = location?.imageUrls
                countOfImages = imageResults?.count
            } else {
                if (location?.imageUrls.count)! > 0 {
                    imageResults = location?.imageUrls
                    countOfImages = imageResults?.count
                } else {
                    initiateImageRequests()
                }
            }
        }
        hintView.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    private func setUpInitialCollectionView() {
        if let noOfImages = countOfImages {
            if noOfImages > 0 {
                imageCollectionView.hideLoader()
                imageCollectionView.reloadData()
                
            } else {
                imageCollectionView.hideLoader()
                imageCollectionView.reloadData()
                imageCollectionView.setEmptyMessage("There is no image :(")
            }
        }
    }
    
    //MARK: - Methods to Fetch Images, Save Images to Directory and DB
    
    // Initiate the request for the list of images
    private func initiateImageRequests() {
        imageCollectionView.showLoader(message: "Fetching Images... please wait...")
        ImageDownloadManager.fetchImageURLList(latitude: (locationAnnotation?.annotation?.coordinate.latitude)!, longitude: (locationAnnotation?.annotation?.coordinate.longitude)!, urlList: updatePinWithURLCount(images:error:))
    }
    
    // The images are fetched for pin and the count is updated in local storage
    private func updatePinWithURLCount(images: TheImageList?, error: Error?) {
        DispatchQueue.main.async { [self] in
            if let theError = error {
                self.imageCollectionView.hideLoader()
                self.imageCollectionView.setEmptyMessage("\(theError.localizedDescription)\n Tap refresh button to reload.")
            }
            
            if let theImageList = images {
                let thePin = RealmHelper.realm.objects(Pins.self).filter("id = %@", self.locationSearchString)
                if let pin = thePin.first {
                    try! RealmHelper.realm.write {
                        pin.numberOfUrls = theImageList.count > self.maxImages ? self.maxImages : theImageList.count
                    }
                    self.countOfImages = self.fetchCounts()
                    self.downloadAndSaveImages(theImageList)
                } else {
                    print("There is no image: \(error!.localizedDescription)")
                }
            }
        }
    }
    
    // Save downloaded images to directory
    private func downloadAndSaveImages(_ images: TheImageList) {
        let dispatchGroup = DispatchGroup()
        if !images.isEmpty && images.count > maxImages {
            for singleImage in images[0..<maxImages] {
                dispatchGroup.enter()
                fetchAndSaveImageToDB(singleImage) { (_) in
                    dispatchGroup.leave()
                }
            }
        } else {
            for singleImage in images {
                dispatchGroup.enter()
                fetchAndSaveImageToDB(singleImage) { (_) in
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.imageResults = self.location?.imageUrls
            self.countOfImages = self.imageResults?.count
            self.imageCollectionView.reloadData()
            self.imageCollectionView.hideLoader()
        }
    }
    
    // Save a single downloaded image to directory and save directory url to db
    private func fetchAndSaveImageToDB(_ singleImage: ImageModel, isDone: @escaping(Bool) -> Void) {
        ImageDownloadManager.fetchImage(url: singleImage.imageURL) { [self] (image) in
            if let directoryUrl = ImageDownloadManager.saveDownloadedImageToDirectory(imageName: singleImage.id, image: image) {
                try! RealmHelper.realm.write {
                    let realmImage = Images()
                    realmImage.directoryURLOFSavedImage = directoryUrl
                    self.location?.imageUrls.append(realmImage)
                    RealmHelper.realm.add(realmImage)
                    isDone(true)
                }
            }
        }
    }
    
    // Retrieve the fetched numberOfUrls field from Pin
    private func fetchCounts() -> ImageCount? {
        let predicate = NSPredicate(format: "id = %@", locationSearchString)
        let thePin = RealmHelper.realm.objects(Pins.self).filter(predicate)
        if let pin = thePin.first {
            return pin.numberOfUrls
        } else {
            return 0
        }
    }
    
    // MARK:- Methods for Button Actions
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteButtonPressed() {
        let deleteAlert = UIAlertController(title: "Confirm delete?", message: "Location will be deleted", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteLocation()
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    fileprivate func deleteLocation() {
        if let locationPin = self.location {
            do {
                try RealmHelper.realm.write {
                    self.deletFiles(files: locationPin.imageUrls)
                    RealmHelper.realm.delete(locationPin.imageUrls)
                    RealmHelper.realm.delete(locationPin)
                    let vc = MapViewController()
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } catch {
                print("Error deleting location, \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func refreshButtonPressed() {
        if let locationPin = location {
            do {
                try RealmHelper.realm.write {
                    deletFiles(files: locationPin.imageUrls)
                    RealmHelper.realm.delete(locationPin.imageUrls)
                    locationPin.numberOfUrls = 0
                    
                    imageResults = nil
                    countOfImages = 0
                    imageCollectionView.setEmptyMessage("")
                    initiateImageRequests()
                }
            } catch {
                print("Error deleting location images, \(error.localizedDescription)")
            }
        }
    }
    
    private func deletFiles(files: ListOfImages) {
        for image in files {
            deleteSingleFileFromDirectory(fileName: image.directoryURLOFSavedImage)
        }
    }
    
    private func deleteSingleFileFromDirectory(fileName: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: imagePath)
        } catch {
            print("Error deleting file, \(error.localizedDescription)")
        }
    }
    
    private func refreshImageRequests() {
         setUpInitialCollectionView()
    }
    
    //MARK:- Methods to Setup Image Album View
    
    private func setupView() {
        view.addSubview(mapViewContainer)
        NSLayoutConstraint.activate([
            mapViewContainer.topAnchor.constraint(equalTo: view.topAnchor),
            mapViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapViewContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
        
        mapViewContainer.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor)
        ])
        
        view.addSubview(imageCollectionView)
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor),
            imageCollectionView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageCollectionView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.heightAnchor.constraint(equalToConstant: 35),
            backButton.widthAnchor.constraint(equalToConstant: 35),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backButton.centerYAnchor.constraint(equalTo: mapViewContainer.centerYAnchor, constant: -15)
        ])
        
        view.addSubview(refreshButton)
        NSLayoutConstraint.activate([
            refreshButton.heightAnchor.constraint(equalToConstant: 35),
            refreshButton.widthAnchor.constraint(equalToConstant: 35),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            refreshButton.centerYAnchor.constraint(equalTo: mapViewContainer.centerYAnchor, constant: -15)
        ])
        
        view.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 35),
            deleteButton.widthAnchor.constraint(equalToConstant: 35),
            deleteButton.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -10),
            deleteButton.centerYAnchor.constraint(equalTo: mapViewContainer.centerYAnchor, constant: -15)
        ])
        
        setupHintView()
    }
    
    private func setupHintView() {
        view.addSubview(hintView)
        NSLayoutConstraint.activate([
            hintView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hintView.heightAnchor.constraint(equalToConstant: 80.0),
            hintView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hintView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])
        
        hintView.addSubview(showViewText)
        NSLayoutConstraint.activate([
            showViewText.centerXAnchor.constraint(equalTo: hintView.centerXAnchor),
            showViewText.centerYAnchor.constraint(equalTo: hintView.centerYAnchor, constant: 20.0)
        ])
    }
    
    //MARK:- Methods to Show and Hide Hint Message
    private func showHint() {
        UIView.animate(withDuration: 1.0) {
            self.hintView.isHidden = false
            self.hintView.layoutIfNeeded()
        }
    }
    
    private func hideHint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 1.0) {
                self.hintView.isHidden = true
                self.hintView.layoutIfNeeded()
            }
        }
    }
    
    func hintCheck() {
        showHint()
        hideHint()
    }
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let _: CGFloat = 5
            let lineSpacing: CGFloat = 1
            let interItemSpacing: CGFloat = 0
            
            let itemSize = self.view.bounds.width / 3 - 2
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            imageCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
}

extension UIButton {
    func styleButton(imageName: String, bodyColor: UIColor, iconColor: UIColor) {
        self.setImage(UIImage(systemName: imageName), for: .normal)
        self.backgroundColor = bodyColor
        self.tintColor = iconColor
        self.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        self.contentMode = .scaleAspectFit
        let shadow = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 35, height: 35), cornerRadius: 11)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.8).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadow.cgPath
    }
}


private extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Avenir", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func showLoader(message msg: String?) {
        let Indicator = MBProgressHUD.showAdded(to: self, animated: true)
        Indicator.isUserInteractionEnabled = true
        Indicator.detailsLabel.text = msg
        Indicator.show(animated: true)
        self.isScrollEnabled = false
    }
    
    func hideLoader() {
        MBProgressHUD.hide(for: self, animated: true)
        self.isScrollEnabled = true
    }
}
