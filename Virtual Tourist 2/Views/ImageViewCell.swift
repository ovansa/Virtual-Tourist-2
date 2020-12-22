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
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let indicator: UIActivityIndicatorView = {
       let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private func setupImageCell() {
        addSubview(mapImageView)
        NSLayoutConstraint.activate([
            mapImageView.topAnchor.constraint(equalTo: topAnchor),
            mapImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageCell()
        mapImageView.showEmptyView()
        indicator.startAnimating()
    }
    
    func configureCell(image: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(image)
        print(imagePath)
        mapImage.image = UIImage(contentsOfFile: imagePath.path)
        indicator.stopAnimating()
        mapImageView.hideEmptyView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func showEmptyView() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray.withAlphaComponent(0.7).cgColor
        
        let color = UIColor(displayP3Red: 248/255, green: 245/255, blue: 238/255, alpha: 1)
        self.backgroundColor = color.withAlphaComponent(0.8)
    }
    
    func hideEmptyView() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = nil
        self.backgroundColor = nil
    }
}
