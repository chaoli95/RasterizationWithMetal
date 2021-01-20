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
    
    #if os(OSX)
    @IBOutlet weak var perspectiveSwitch: NSSwitch!
    @IBOutlet weak var animationSwitch: NSSwitch!
    @IBOutlet weak var shadingControl: NSSegmentedControl!
//    @IBOutlet weak var fovSlider: NSSlider!
    #else
    @IBOutlet weak var perspectiveSwitch: UISwitch!
    @IBOutlet weak var animationSwitch: UISwitch!
    @IBOutlet weak var shadingControl: UISegmentedControl!
//    @IBOutlet weak var fovSlider: UISlider!
    #endif
    
    @IBAction func shadingControlAction(_ sender: Any) {
        #if os(iOS)
//            print(shadingControl.selectedSegmentIndex)
        self.renderer?.shadingType = ShadingType.init(rawValue: shadingControl.selectedSegmentIndex)!
        
        #else
//            print(shadingControl.selectedSegment)
        self.renderer?.shadingType = ShadingType.init(rawValue: shadingControl.selectedSegment)!
        
        #endif
    }
    @IBAction func perspectiveSwitched(_ sender: Any) {
        #if os(iOS)
//        print(self.perspectiveSwitch.isOn)
        self.renderer?.setPerspective(perspective: self.perspectiveSwitch.isOn)
        #else
//        print(self.perspectiveSwitch.state)
        self.renderer?.setPerspective(perspective: self.perspectiveSwitch.state == .on)
        #endif
    }
    @IBAction func animationSwitched(_ sender: Any) {
        #if os(iOS)
//        print(self.animationSwitch.isOn)
        self.renderer?.setAnimation(animation: self.animationSwitch.isOn)
        #else
//        print(self.animationSwitch.state)
        self.renderer?.setAnimation(animation: self.animationSwitch.state == .on)
        #endif
    }
    
//    @IBAction func sliderValueChanged(_ sender: Any) {
//        #if os(iOS)
//        print(self.fovSlider.value)
//        #else
//        print(self.fovSlider.floatValue)
//        #endif
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mtkView = self.view as? MTKView {
            self.mtkView = mtkView
            self.mtkView?.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
            mtkView.device = MTLCreateSystemDefaultDevice()
            
//            if let url = Bundle.main.url(forResource: "bunny", withExtension: "off") {
//                guard let mesh = Mesh.ini else { return }
            let meshName = "spot"
            let meshExtension = "obj"
            guard let mesh = Mesh.init(forResource: meshName, withExtension: meshExtension) else { return }
//            let textureURL: URL? = Bundle.main.url(forResource: "spot", withExtension: "png")
//            let textureURL = Bundle.main.url(forResource: "spot", withExtension: "png", subdirectory: "Assets.xcassets")

            let textureURL = Bundle.main.url(forResource: meshName, withExtension: "png")
            guard let renderer = Renderer.init(with: mtkView, mesh: mesh, textureURL: textureURL) else {
                    print("renderer initialization failed")
                    return
                }
                self.renderer = renderer
                renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                mtkView.delegate = renderer
//            } else {
//                print("no such path: bunny.off")
//            }
            
            
        }
    }
}
