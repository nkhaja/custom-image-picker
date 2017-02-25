//
//  ViewController.swift
//  CustomPhotoLibarary
//
//  Created by Nabil K on 2017-02-10.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

//"http://stackoverflow.com/questions/28259961/swift-how-to-get-last-taken-3-photos-from-photo-library"

//http://stackoverflow.com/questions/38168032/how-to-get-image-metadata-in-ios-9-using-photos-framework



protocol KhajaPhotoLibraryDelegate: class{
    func getSelectedLibrary(images:[UIImage])
}

protocol PhotoFetcher: class{
    func getImages(completion: @escaping ([UIImage]) -> ())
}


import UIKit
import Photos

class PhotoLibraryController: UIViewController, PhotoFetcher {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var images = [UIImage]()
    var selectedImage: UIImage?
    var multiSelect: Bool = false
    var selectedIndexes: [Int:Bool] = [:]
//    weak var delegate: Mappable?
    weak var delegate: KhajaPhotoLibraryDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImages { images in
            self.images = images
            self.collectionView.reloadData()
        }

        
        submitButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(multiSelectPressed))
    }
    
    
    func multiSelectPressed(){
        multiSelect = !multiSelect
        self.submitButton.isHidden = !multiSelect
        self.selectedIndexes.removeAll()
        self.collectionView.reloadData()
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        var photosToSend = [UIImage]()
        
        for (key, value) in selectedIndexes {
            if value{
                photosToSend.append(self.images[key])
            }
        }
        
        if delegate != nil  && images.count > 0{
            delegate!.getSelectedLibrary(images:photosToSend)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: SeeImageController.self){
            if let seeImageController = segue.destination as? SeeImageController{
                seeImageController.image = selectedImage
            }
        }
    }
    
}


extension PhotoLibraryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetCollectionCell.self), for: indexPath) as! AssetCollectionCell
        
        let row = indexPath.row
        
        
        if multiSelect {
            cell.checkBox.isHidden = false
            cell.layer.borderWidth = 5
            
            // check to see if this box is selected
            if let selected = selectedIndexes[row]{
                if selected{
                    cell.checkBox.image = #imageLiteral(resourceName: "checkmark")
                    cell.layer.borderColor = UIColor.green.cgColor
                }
                    
                else {
                    cell.checkBox.image = nil
                    cell.layer.borderColor = UIColor.black.cgColor
                }
            }
                
            else {
                cell.checkBox.image = nil
                cell.layer.borderColor = UIColor.black.cgColor
            }
        }
            
        else{
            cell.checkBox.isHidden = true
            cell.layer.borderWidth = 0
        }
        
        
        cell.imageView.image = images[row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.row
        selectedImage = images[row]
        
        if multiSelect{
            //this item has been selected before
            if let selected = selectedIndexes[row]{
                if selected {
                    selectedIndexes[row] = false
                }
                else{
                    selectedIndexes[row] = true
                }
            }
                
                // this item is being selected for the first time
            else{
                selectedIndexes[row] = true
            }
            
            self.collectionView.reloadItems(at: [indexPath])
        }
            
        else{
            performSegue(withIdentifier: String(describing: SeeImageController.self), sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}




// Currenlty repeating activity with asset getting; refactor



extension PhotoFetcher {
    
    
    
    func fetchPhotos(imgManager: PHImageManager, fetchResult: PHFetchResult<PHAsset>, requestOptions: PHImageRequestOptions, completion: @escaping ([UIImage]) -> ()){
        
        var output = [UIImage]()
        let output_dispatch = DispatchGroup()
        
        
        
        //Options for retrieving meta data
        let editingOtions = PHContentEditingInputRequestOptions()
        editingOtions.isNetworkAccessAllowed = true
        
        for i in 0..<fetchResult.count {
            
            let asset = fetchResult.object(at: i)
            output_dispatch.enter()
            
            
            // desired size of returned images
            let size = CGSize(width: 200, height: 200)
            
            // Only returning photos with image data, Request the image of given quality sychronously
            imgManager.requestImage(for: asset,
                                    targetSize: size,
                                    contentMode: .aspectFit,
                                    options: requestOptions,
                                    resultHandler: { image, info in
                                            output.append(image!)
                        
            })
            
            
            output_dispatch.leave()
            
        }
        
        output_dispatch.notify(queue: DispatchQueue.main) {
            completion(output)
        }
    }
    
    
    func getImages(completion: @escaping ([UIImage]) -> ()){
        // Declare a singleton of PHImangeManger class
        let imgManager = PHImageManager.default()
        
        // Requestion options determine media type, and quality
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        // Options for retrieving photos
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        
        if fetchResult.count > 0 {
            fetchPhotos(imgManager: imgManager, fetchResult: fetchResult, requestOptions: requestOptions, completion: { images in
                completion(images)
            })
        }
            
        else{
            return
        }
    }
}
