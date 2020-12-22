//
//  ImageAlbumController+extension.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 22/12/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit

extension ImageAlbumController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath) as! ImageViewCell
        
        if imageResults != nil {
            cell.configureCell(image: imageResults![indexPath.item].directoryURLOFSavedImage)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countOfImages ?? 0
    }
}

extension ImageAlbumController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedImage = imageResults?[indexPath.item] {
            let vc = ImageViewController()
            vc.imageString = selectedImage.directoryURLOFSavedImage
            vc.imageLocation = location
            vc.selectedIndex = indexPath.item
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            hintCheck()
        }
    }
}

extension ImageAlbumController: SendControlIdDelegate {
    func sendId(controlId: String) {
        sentControlId = controlId
    }
}
