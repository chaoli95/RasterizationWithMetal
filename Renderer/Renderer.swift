//
//  Renderer.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 11/30/20.
//

import Foundation
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
//    private weak var mtkView: MTKView?
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var viewPortSize: SIMD2<UInt32>
    var depthState: MTLDepthStencilState
    var buffer: MTLBuffer
    var lines: [Vertex]
    
    init?(with mtkView: MTKView, lines: [Vertex]) {
        if let device = mtkView.device {
            self.device = device
            self.lines = lines
            self.buffer = device.makeBuffer(length: MemoryLayout<Vertex>.size * lines.count,
                                            options: .storageModeShared)!
            print(self.buffer.allocatedSize)
            self.buffer.contents().copyMemory(from: lines, byteCount: MemoryLayout<Vertex>.size * lines.count)
            
                
            mtkView.depthStencilPixelFormat = .depth32Float
//            mtkView.clearDepth = xxx
            
            let defaultLibrary = device.makeDefaultLibrary()!
            
            let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
            let fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor.init()
            pipelineStateDescriptor.label = "Simple Pipeline"
            pipelineStateDescriptor.vertexFunction = vertexFunction
            pipelineStateDescriptor.fragmentFunction = fragmentFunction
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
            do {
                try self.pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            } catch {
                return nil
            }
            
            let depthDescriptor = MTLDepthStencilDescriptor.init()
            depthDescriptor.depthCompareFunction = .always
            depthDescriptor.isDepthWriteEnabled = true
            if let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) {
                self.depthState = depthState
            } else {
                return nil
            }
            
            self.commandQueue = device.makeCommandQueue()!
            self.viewPortSize = SIMD2<UInt32>()
                
            super.init()
            return
        }
        return nil
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.viewPortSize.x = UInt32(size.width)
        self.viewPortSize.y = UInt32(size.height)
    }
    
    func draw(in view: MTKView) {
        var uniform = Uniform.init()
        let projection = [SIMD4<Float>(1,0,0,0), SIMD4<Float>(0,1,0,0), SIMD4<Float>(0,0,3,-2), SIMD4<Float>(0,0,1,0)]
        uniform.projectionMatrix = matrix_float4x4(rows: projection)
        let orthodox = [SIMD4<Float>(1,0,0,0), SIMD4<Float>(0,1,0,0), SIMD4<Float>(0,0,1,-1), SIMD4<Float>(0,0,0,1)]
        uniform.orthodoxMatrix = matrix_float4x4(rows: orthodox)
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            let commandBuffer = self.commandQueue.makeCommandBuffer()
            commandBuffer?.label = "MyCommand"
            
            if let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.label = "MyRenderEncoder"
                renderEncoder.setViewport(MTLViewport.init(originX: 0.0,
                                                           originY: 0.0,
                                                           width: Double(self.viewPortSize.x),
                                                           height: Double(self.viewPortSize.y),
                                                           znear: 0.0,
                                                           zfar: 1.0))
                renderEncoder.setRenderPipelineState(self.pipelineState)
    
//                renderEncoder.setVertexBytes(self.buffer,
//                                             length: MemoryLayout<Vertex>.size * triangleVertices.count,
//                                             index: Int(VertexInputIndexVertices.rawValue))
                renderEncoder.setVertexBuffer(self.buffer, offset: 0, index: 0)
                renderEncoder.setVertexBytes(&viewPortSize,
                                             length: MemoryLayout<SIMD2<UInt32>>.size,
                                             index: Int(VertexInputIndexViewportSize.rawValue))
                renderEncoder.setVertexBytes(&uniform,
                                             length: MemoryLayout<Uniform>.size,
                                             index: Int(VertexInputIndexUniform.rawValue))
//                var i = 0
//                while i < self.lines.count {
//                    renderEncoder.setVertexBufferOffset(i * MemoryLayout<Vertex>.size, index: 0)
                renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: self.lines.count)
//                    i += 2
//                }
                
                renderEncoder.endEncoding()
            }
            
            commandBuffer?.present(view.currentDrawable!)
            commandBuffer?.commit()
            
        }
    }
}
