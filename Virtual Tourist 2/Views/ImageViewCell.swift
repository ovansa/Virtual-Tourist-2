//
//  ImageViewCell.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 30/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImageViewCell: UICollectionViewCell {
    let mapImageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mapImage: UIImageView = {
        let image = UIImageView()
//        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let indicator: UIActivityIndicatorView = {
       let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mapImageView)
        NSLayoutConstraint.activate([
            mapImageView.topAnchor.constraint(equalTo: topAnchor),
            mapImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        mapImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
        
        mapImageView.addSubview(mapImage)
        NSLayoutConstraint.activate([
            mapImage.topAnchor.constraint(equalTo: mapImageView.topAnchor),
            mapImage.leadingAnchor.constraint(equalTo: mapImageView.leadingAnchor),
            mapImage.trailingAnchor.constraint(equalTo: mapImageView.trailingAnchor),
            mapImage.bottomAnchor.constraint(equalTo: mapImageView.bottomAnchor)
        ])
        
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: mapImageView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: mapImageView.centerYAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 30.0),
            indicator.widthAnchor.constraint(equalToConstant: 30.0)
        ])
        indicator.startAnimating()
    }
    
    func configureCell(image: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(image)
        print(imagePath)
        mapImage.image = UIImage(contentsOfFile: imagePath.path)
        indicator.stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mapImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    
    func showLoader(message msg: String?) {
        
    }
    
    func hideLoader() {
        
    }
}
