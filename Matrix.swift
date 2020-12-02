//
//  Matrix.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/2/20.
//

import Foundation
import simd

func makeTranslateMatrix(tx: Float, ty: Float, tz: Float) -> matrix_float4x4 {
    let rows = [
        simd_float4(1, 0, 0, tx),
        simd_float4(0, 1, 0, ty),
        simd_float4(0, 0, 1, tz),
        simd_float4(0, 0, 0, 1),
    ]
    return matrix_float4x4(rows: rows)
}

func makeScaleMatrix(scaleX:Float, scaleY: Float, scaleZ: Float) -> matrix_float4x4 {
    let rows = [
        simd_float4(scaleX, 0, 0, 0),
        simd_float4(0, scaleY, 0, 0),
        simd_float4(0, 0, scaleZ, 0),
        simd_float4(0, 0, 0, 1),
    ]
    return matrix_float4x4(rows: rows)
}
