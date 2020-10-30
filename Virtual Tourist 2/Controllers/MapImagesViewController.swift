//
//  MapImagesViewController.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 28/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MapKit

class MapImagesViewController: UIViewController {
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
    
    var location: Pins?
    var locationAnnotation: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        configureNavBar()
        setupView()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionCellId)
        
        if let annotationData = locationAnnotation {
            let latitude = annotationData.annotation?.coordinate.latitude
            let longitude = annotationData.annotation?.coordinate.longitude
            let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(mapRegion, animated: true)
            mapView.addAnnotation(annotationData.annotation!)
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
            
            let itemSize = self.view.bounds.width / 3 - 2
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize + 20)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            imageCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
}

extension MapImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath)
        cell.backgroundColor = .red
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
