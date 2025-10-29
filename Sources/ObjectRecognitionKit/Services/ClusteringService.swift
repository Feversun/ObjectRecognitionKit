//
//  ClusteringService.swift
//  ObjectRecognitionKit
//
//  主体聚类服务 - 基于特征向量的相似度聚类
//

import Foundation
import Accelerate

/// 聚类服务
public class ClusteringService {
    
    public init() {}
    
    /// 将主体聚类为实体
    /// - Parameters:
    ///   - subjects: 待聚类的主体数组
    ///   - threshold: 相似度阈值 (0-1, 默认 0.7)
    /// - Returns: 聚类后的实体数组
    public func clusterSubjects(_ subjects: [RecognizedSubject], threshold: Float = 0.7) -> [RecognizedEntity] {
        guard !subjects.isEmpty else { return [] }
        
        var entities: [RecognizedEntity] = []
        var assignedSubjects = Set<String>()
        
        for subject in subjects {
            // 跳过已分配的主体
            if assignedSubjects.contains(subject.id) {
                continue
            }
            
            // 创建新实体
            var entitySubjects: [RecognizedSubject] = [subject]
            assignedSubjects.insert(subject.id)
            
            // 查找相似主体
            for otherSubject in subjects {
                if assignedSubjects.contains(otherSubject.id) {
                    continue
                }
                
                let similarity = cosineSimilarity(subject.featureVector, otherSubject.featureVector)
                
                if similarity >= threshold {
                    entitySubjects.append(otherSubject)
                    assignedSubjects.insert(otherSubject.id)
                }
            }
            
            // 创建实体
            let avgConfidence = entitySubjects.map { $0.confidence }.reduce(0, +) / Double(entitySubjects.count)
            let entity = RecognizedEntity(
                averageConfidence: avgConfidence,
                subjectCount: entitySubjects.count,
                representativeImagePath: entitySubjects.first?.imagePath
            )
            
            entities.append(entity)
        }
        
        return entities
    }
    
    /// 计算余弦相似度
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count && !a.isEmpty else { return 0 }
        
        var dotProduct: Float = 0
        var magnitudeA: Float = 0
        var magnitudeB: Float = 0
        
        vDSP_dotpr(a, 1, b, 1, &dotProduct, vDSP_Length(a.count))
        
        var aSquared = [Float](repeating: 0, count: a.count)
        var bSquared = [Float](repeating: 0, count: b.count)
        vDSP_vsq(a, 1, &aSquared, 1, vDSP_Length(a.count))
        vDSP_vsq(b, 1, &bSquared, 1, vDSP_Length(b.count))
        
        vDSP_sve(aSquared, 1, &magnitudeA, vDSP_Length(aSquared.count))
        vDSP_sve(bSquared, 1, &magnitudeB, vDSP_Length(bSquared.count))
        
        magnitudeA = sqrt(magnitudeA)
        magnitudeB = sqrt(magnitudeB)
        
        guard magnitudeA > 0 && magnitudeB > 0 else { return 0 }
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
    
    /// 计算两个主体的相似度
    /// - Parameters:
    ///   - subject1: 主体1
    ///   - subject2: 主体2
    /// - Returns: 相似度 (0-1)
    public func similarity(between subject1: RecognizedSubject, and subject2: RecognizedSubject) -> Float {
        return cosineSimilarity(subject1.featureVector, subject2.featureVector)
    }
}
