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
        view.backgroundColor = .brown
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
        collectionView.backgroundColor = .cyan
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let collectionCellId = "cellId"
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var eat: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        confirgureNavBarToHidden()
        setupView()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionCellId)
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
            imageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func confirgureNavBarToHidden() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let _: CGFloat = 5
            let lineSpacing: CGFloat = 1
            let interItemSpacing: CGFloat = 1
            
            let itemSize = self.view.bounds.width / 4 - 6
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize + 20)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            imageCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
}

extension MapImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}
