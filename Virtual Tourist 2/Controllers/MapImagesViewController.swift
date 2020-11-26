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

class MapImagesViewController: UIViewController {
    
    let maxImages = 42
    
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
    
    let backButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
    
    let collectionCellId = "cellId"
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
    
    // On loading view, display a loader
    // While displaying loader, fetch count of location from local storage
    // If count is 0, make request to fetch new count from API, and store new count in local storage
    // If count is greater than 0, set the count of location to urlcount
    // And fetch the directory image urls attached to location
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        setupView()
        
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
    
    func setUpInitialCollectionView() {
        
        if let noOfImages = countOfImages {
            print("Count of images \(noOfImages)")
            if noOfImages > 0 {
                imageCollectionView.hideLoader()
                imageCollectionView.reloadData()
                
            } else {
                imageCollectionView.hideLoader()
                imageCollectionView.reloadData()
                imageCollectionView.setEmptyMessage("There is no imnage")
                
            }
        }
    }
    
    //MARK: - Fetch the list of image urls and save count to database
    
    // Initiate the request for the list of images
    func initiateImageRequests() {
        imageCollectionView.showLoader(message: "Please wait...")
        ImageDownloadManager.fetchImageURLList(latitude: (locationAnnotation?.annotation?.coordinate.latitude)!, longitude: (locationAnnotation?.annotation?.coordinate.longitude)!, urlList: updatePinWithURLCount(images:error:))
    }
    
    // The images are fetched for pin and the count is updated in local storage
    func updatePinWithURLCount(images: TheImageList?, error: Error?) {
        DispatchQueue.main.async { [self] in
            if let theError = error {
                print("Error fetching urls: \(theError)")
            }
            
            if let theImageList = images {
                let thePin = RealmHelper.realm.objects(Pins.self).filter("id = %@", self.locationSearchString)
                if let pin = thePin.first {
                    try! RealmHelper.realm.write {
                        pin.numberOfUrls = theImageList.count > maxImages ? maxImages : theImageList.count
                    }
                    // Set the count for collectionView
                    self.countOfImages = self.fetchCounts()
                    print("Printing count from UpdatePinWithURL \(String(describing: self.countOfImages))")
                    // Make request to download images and then save to directory
                    self.downloadAndSaveImageToDirectory(theImageList)
                } else {
                    print("There is no image: \(error.debugDescription)")
                }
            }
        }
    }
    
    // Save downloaded 
    func downloadAndSaveImageToDirectory(_ images: TheImageList) {
        let dispatchGroup = DispatchGroup()
        if !images.isEmpty && images.count > maxImages {
            for singleImage in images[0..<maxImages] {
                dispatchGroup.enter()
                fetchAndSaveImageToRealmDB(singleImage) { (_) in
                    dispatchGroup.leave()
                }
            }
        } else {
            for singleImage in images {
                dispatchGroup.enter()
                fetchAndSaveImageToRealmDB(singleImage) { (_) in
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("Finished fetching images")
            self.imageResults = RealmHelper.retrieveImageURLs(self.locationSearchString)
            self.countOfImages = self.imageResults?.count
            self.imageCollectionView.reloadData()
            self.imageCollectionView.hideLoader()
        }
    }
    
    private func fetchAndSaveImageToRealmDB(_ singleImage: ImageModel, isDone: @escaping(Bool) -> Void) {
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
    func fetchCounts() -> ImageCount? {
        let predicate = NSPredicate(format: "id = %@", locationSearchString)
        let thePin = RealmHelper.realm.objects(Pins.self).filter(predicate)
        
        if let pin = thePin.first {
            return pin.numberOfUrls
        } else {
            return 0
        }
    }
    
    @objc func backButtonPressed() {
        print("Back is tapped")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteButtonPressed() {
        print("Delete is tapped")
    }
    
    @objc func refreshButtonPressed() {
        print("Refresh is tapped")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    func setupView() {
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
    }
    
    func configureNavBar() {
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
    
    func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let _: CGFloat = 5
            let lineSpacing: CGFloat = 1
            let interItemSpacing: CGFloat = 1
            
            let itemSize = self.view.bounds.width / 3 - 1
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize + 20)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            imageCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
}

extension MapImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countOfImages ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath) as! ImageViewCell
        
        if imageResults != nil {
            cell.configureCell(image: imageResults![indexPath.item].directoryURLOFSavedImage)
        }

        return cell
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

extension UICollectionView {
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
