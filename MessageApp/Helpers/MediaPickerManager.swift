//
//  MediaPickerManagers.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/16.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import Photos


class MediaPickerManager: NSObject {
    func getImage(_ info:[UIImagePickerController.InfoKey : Any], complition: @escaping(UIImage) -> ()){
        if let asset = info[.phAsset] as? PHAsset {
            
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 100, height: 100),
                                                  contentMode: .aspectFit,
                                                  options: nil) { image, info in
                                                    guard let image = image else { return }
                                                    
                                                    complition(image)
                                                    
            }
            
        } else if let image = info[.originalImage] as? UIImage {
            complition(image)
        }
    }
}
