//
//  SubjectRecognitionService.swift
//  ObjectRecognitionKit
//
//  主体识别服务 - 使用 Vision 框架
//

import Foundation
import UIKit
import Vision

/// 主体识别服务
@available(iOS 17.0, *)
public class SubjectRecognitionService {
    
    public init() {}
    
    /// 从图片中识别所有主体
    /// - Parameter image: 输入图片
    /// - Returns: 识别结果数组 (图片, 置信度, 边界框)
    public func recognizeSubjects(from image: UIImage) async throws -> [(image: UIImage, confidence: Double, boundingBox: CGRect)] {
        guard let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateForegroundInstanceMaskRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNInstanceMaskObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                var subjects: [(UIImage, Double, CGRect)] = []
                
                for observation in results {
                    do {
                        let maskedPixelBuffer = try observation.generateMaskedImage(
                            ofInstances: observation.allInstances,
                            from: handler,
                            croppedToInstancesExtent: true
                        )
                        
                        let ciImage = CIImage(cvPixelBuffer: maskedPixelBuffer)
                        let context = CIContext()
                        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                            let uiImage = UIImage(cgImage: cgImage)
                            subjects.append((uiImage, Double(observation.confidence), observation.boundingBox))
                        }
                    } catch {
                        print("警告: 生成主体图像失败 - \(error)")
                    }
                }
                
                continuation.resume(returning: subjects)
            }
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// 提取特征向量
    /// - Parameter image: 输入图片
    /// - Returns: 特征向量
    public func extractFeatureVector(from image: UIImage) async throws -> [Float] {
        guard let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateImageFeaturePrintRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                    continuation.resume(throwing: RecognitionError.noFeatureExtracted)
                    return
                }
                
                let featureData = observation.data
                let floatArray = featureData.withUnsafeBytes { pointer in
                    Array(pointer.bindMemory(to: Float.self))
                }
                
                continuation.resume(returning: floatArray)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

/// 识别错误类型
public enum RecognitionError: LocalizedError {
    case invalidImage
    case noFeatureExtracted
    case recognitionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "无效的图片"
        case .noFeatureExtracted:
            return "无法提取特征向量"
        case .recognitionFailed(let message):
            return "识别失败: \(message)"
        }
    }
}
