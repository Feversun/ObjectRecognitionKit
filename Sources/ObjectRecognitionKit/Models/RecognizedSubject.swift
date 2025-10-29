//
//  RecognizedSubject.swift
//  ObjectRecognitionKit
//
//  识别出的主体数据模型(不依赖 SwiftData)
//

import Foundation
import UIKit

/// 识别出的主体
public struct RecognizedSubject: Identifiable, Codable {
    public let id: String
    public var imagePath: String
    public var thumbnailPath: String?
    public var boundingBox: CGRect?
    public var confidence: Double
    public var featureVector: [Float]
    public var extractedAt: Date
    public var extractionMethod: ExtractionMethod
    public var entityId: String?
    public var isMarkedAsNonTarget: Bool
    public var lastAdjustedAt: Date?
    
    public enum ExtractionMethod: String, Codable {
        case auto
        case manual
    }
    
    public init(
        id: String = UUID().uuidString,
        imagePath: String,
        thumbnailPath: String? = nil,
        boundingBox: CGRect? = nil,
        confidence: Double,
        featureVector: [Float] = [],
        extractedAt: Date = Date(),
        extractionMethod: ExtractionMethod = .auto,
        entityId: String? = nil,
        isMarkedAsNonTarget: Bool = false,
        lastAdjustedAt: Date? = nil
    ) {
        self.id = id
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.boundingBox = boundingBox
        self.confidence = confidence
        self.featureVector = featureVector
        self.extractedAt = extractedAt
        self.extractionMethod = extractionMethod
        self.entityId = entityId
        self.isMarkedAsNonTarget = isMarkedAsNonTarget
        self.lastAdjustedAt = lastAdjustedAt
    }
}

/// 识别出的实体(聚类结果)
public struct RecognizedEntity: Identifiable, Codable {
    public let id: String
    public var customName: String?
    public var averageConfidence: Double
    public var subjectCount: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var representativeImagePath: String?
    
    public init(
        id: String = UUID().uuidString,
        customName: String? = nil,
        averageConfidence: Double = 0,
        subjectCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        representativeImagePath: String? = nil
    ) {
        self.id = id
        self.customName = customName
        self.averageConfidence = averageConfidence
        self.subjectCount = subjectCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.representativeImagePath = representativeImagePath
    }
}
