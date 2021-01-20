//
//  Camera.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/2/20.
//

import Foundation
import simd


class Camera {

    var position: simd_float3
    var w: simd_float3
    var u: simd_float3
    var v: simd_float3
    
    var fieldOfView: Float
    var right: Float
    var top: Float
    var near: Float
    var far: Float
    var aspectRatio: Float {
        didSet {
            self.right = top * aspectRatio
            self.canonical = makeScaleMatrix(scaleX: 1 / right, scaleY: 1 / top, scaleZ: 1 / (far - near)) * makeTranslateMatrix(tx: 0, ty: 0, tz: -near)
            self.worldToCanonical = self.canonical * self.perspectiveMatrix * self.worldToCamera
        }
    }
    
    var perspective: Bool
    
    var worldToCamera: matrix_float4x4
    var perspectiveMatrix: matrix_float4x4
    var canonical: matrix_float4x4
    var worldToCanonical: matrix_float4x4
    
    init(position: simd_float3, upDirection: simd_float3, fieldOfView: Float, aspectRatio: Float, near: Float, far: Float, perspective: Bool) {
        self.position = position
        self.w = simd.normalize(-position)
        self.v = simd.normalize(upDirection)
        self.u = simd_cross(w, v)
        
        assert(near > 0 && far > near)
        self.near = near
        self.far = far
        assert(fieldOfView >= 0 && fieldOfView < Float.pi)
        self.fieldOfView = fieldOfView
        self.top = near * tan(fieldOfView / 2)
        self.right = top * aspectRatio
        self.aspectRatio = aspectRatio
        
        self.perspective = perspective
        
        self.worldToCamera = simd_inverse(matrix_float4x4(vector_float4(u, 0),
                                                          vector_float4(v, 0),
                                                          vector_float4(w, 0),
                                                          vector_float4(position, 1)))
        if perspective {
            self.perspectiveMatrix = matrix_float4x4(vector_float4(near, 0, 0, 0),
                                                     vector_float4(0, near, 0, 0),
                                                     vector_float4(0, 0, (near + far), 1),
                                                     vector_float4(0, 0, -near*far, 0))
        } else {
            self.perspectiveMatrix = matrix_float4x4(1)
        }
        self.canonical = makeScaleMatrix(scaleX: 1 / right, scaleY: 1 / top, scaleZ: 1 / (far - near)) * makeTranslateMatrix(tx: 0, ty: 0, tz: -near)
        
        self.worldToCanonical = self.canonical * self.perspectiveMatrix * self.worldToCamera
    }
    
    func setPerspective(persepctive: Bool, fov: Float) {
        self.fieldOfView = fov
        self.perspective = persepctive
        if perspective {
            self.perspectiveMatrix = matrix_float4x4(vector_float4(near, 0, 0, 0),
                                                     vector_float4(0, near, 0, 0),
                                                     vector_float4(0, 0, (near + far), 1),
                                                     vector_float4(0, 0, -near * far, 0))
        } else {
            self.perspectiveMatrix = matrix_float4x4(1)
        }
        self.top = near * tan(fov / 2)
        self.right = self.top * self.aspectRatio
        self.canonical = makeScaleMatrix(scaleX: 1 / right, scaleY: 1 / top, scaleZ: 1 / (far - near)) * makeTranslateMatrix(tx: 0, ty: 0, tz: -near)
        self.worldToCanonical = self.canonical * self.perspectiveMatrix * self.worldToCamera
    }
}
