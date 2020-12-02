//
//  ViewController.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/1/20.
//

import Foundation
import MetalKit

#if canImport(UIKit)
    import UIKit
    typealias PlatformViewController = UIViewController
#else
    import Cocoa
    typealias PlatformViewController = NSViewController
#endif


    
class ViewController: PlatformViewController {
    private var renderer: Renderer?
    private var mtkView: MTKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mtkView = self.view as? MTKView {
            self.mtkView = mtkView
            mtkView.device = MTLCreateSystemDefaultDevice()
            
            if let path = Bundle.main.path(forResource: "bunny", ofType: "off") {
                guard let mesh = Mesh.init(with: path) else { return }
                if let renderer = Renderer.init(with: mtkView, lines: mesh.lines) {
                    self.renderer = renderer
                    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                    mtkView.delegate = renderer
                } else {
                    print("renderer initialization failed")
                    return
                }
            } else {
                print("no such path: bunny.off") 
            }
            
            
        }
    }
}
