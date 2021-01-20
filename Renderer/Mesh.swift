//
//  Mesh.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/1/20.
//

import Foundation
import simd

struct Mesh {
    let vertices: [simd_float3]
    let facets: [simd_uint3]
    let verteicesNormal: [simd_float3]?
    let facetsNormal: [simd_float3]?
    let textureCoordinates: [simd_float2]?
    let facetTexture: [simd_uint3]?
    
    let min: simd_float3
    let max: simd_float3
    let midpoint: simd_float3
    
    var lines: [Vertex]
    var triangles: [Vertex]
    var trianglesPerVertex: [Vertex]
    
    init?(forResource resource: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else {
            return nil
        }
        let data: String
        do {
            data = try String(contentsOf: url)
        } catch let err as NSError {
            print(err.description)
            return nil
        }
        let contents = data.components(separatedBy: NSCharacterSet.newlines)
        var vertices: [simd_float3] = []
        self.lines = []
        self.triangles = []
        self.trianglesPerVertex = []
        switch ext {
        case "off":
            let nums = contents[1].components(separatedBy: NSCharacterSet.whitespaces)
            let nv = Int(nums[0])!
            let nf = Int(nums[1])!
            vertices = contents[2..<2+nv].map({ (line) -> simd_float3 in
                let vString = line.components(separatedBy: NSCharacterSet.whitespaces)
                return simd_float3(Float(vString[0])!, Float(vString[1])!, Float(vString[2])!)
            })
            self.vertices = vertices
            self.facets = contents[2+nv..<2+nv+nf].map({
                let facet = $0.components(separatedBy: NSCharacterSet.whitespaces)
                return simd_uint3(UInt32(facet[1])!, UInt32(facet[2])!, UInt32(facet[3])!)
            })
            self.textureCoordinates = nil
            self.facetTexture = nil
        case "obj":
            vertices = contents.filter({
                return $0.starts(with: "v ")
            }).map({
                let strs = $0.components(separatedBy: NSCharacterSet.whitespaces)
                return simd_float3(Float(strs[1])!, Float(strs[2])!, Float(strs[3])!)
            })
            self.vertices = vertices
            self.facets = contents.filter({
                return $0.starts(with: "f")
            }).map({
                let strs = $0.components(separatedBy: NSCharacterSet.whitespaces)
                let facet = strs.suffix(from: 1).map { (str) -> UInt32 in
                    return UInt32(str.split(separator: "/")[0])! - 1
                }
                return simd_uint3(facet[0], facet[1], facet[2])
            })
            
            self.textureCoordinates = contents.filter({
                return $0.starts(with: "vt")
            }).map({
                let strs = $0.components(separatedBy: NSCharacterSet.whitespaces)
                return simd_float2(Float(strs[1])!, 1 - Float(strs[2])!)
            })
            self.facetTexture = contents.filter({
                return $0.starts(with: "f")
            }).map({
                let strs = $0.components(separatedBy: NSCharacterSet.whitespaces)
                let facet = strs.suffix(from: 1).map { (str) -> UInt32 in
                    return UInt32(str.split(separator: "/")[1])! - 1
                }
                return simd_uint3(facet[0], facet[1], facet[2])
            })
        default:
            return nil
        }
        self.min = self.vertices.reduce(simd_float3(repeating: Float.greatestFiniteMagnitude), { (min, value) -> simd_float3 in
            return simd_min(min, value)
        })
        self.max = self.vertices.reduce(simd_float3(repeating: Float.leastNormalMagnitude), { (max, value) -> simd_float3 in
            return simd_max(max, value)
        })
        print(self.max - self.min)
        self.midpoint = (self.min + self.max) / 2
        self.facetsNormal = self.facets.map({ (facet) -> simd_float3 in
            let u = vertices[Int(facet[1])] - vertices[Int(facet[0])]
            let v = vertices[Int(facet[2])] - vertices[Int(facet[0])]
            return simd_normalize(simd_cross(u, v))
        })
        var verteicesNormal = [simd_float3](repeating: simd_float3(), count: self.vertices.count)
        for i in 0..<facets.count {
            let facet = facets[i]
            for j in 0...2 {
                verteicesNormal[Int(facet[j])] += self.facetsNormal![i]
            }
        }
        self.verteicesNormal = verteicesNormal.map({
            return simd_normalize($0)
        })
        for i in 0..<facets.count {
            for j in 0...2 {
                var coordinate = simd_float2(0, 0)
                if let texture = self.facetTexture?[i] {
                    coordinate = self.textureCoordinates![Int(texture[j])]
                }
                self.lines.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                         normal: vector_float4(), textureCoordinate: simd_float2(0, 0)))
                self.lines.append(Vertex(position: vector4(self.vertices[Int(facets[i][(j+1)%3])], 1),
                                         normal: vector_float4(), textureCoordinate: simd_float2(0, 0)))
                self.triangles.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                             normal: vector_float4(self.facetsNormal![i], 0), textureCoordinate: coordinate))
                self.trianglesPerVertex.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                                      normal: vector_float4(self.verteicesNormal![Int(facets[i][j])], 1), textureCoordinate: coordinate))
            }
        }
    }
}
