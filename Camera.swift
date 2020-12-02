//
//  Camera.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/2/20.
//

import Foundation

protocol CameraDelegate: AnyObject {
    func cameraDidChange()
}

class Camera {
    weak var delegate: CameraDelegate?
    
    init() {
        
    }
}
