//
//  StorageProvider.swift
//  ObjectRecognitionKit
//
//  存储层抽象协议
//

import Foundation
import UIKit

/// 图片存储协议
public protocol ImageStorageProvider {
    /// 保存图片
    func saveImage(_ image: UIImage, identifier: String) async throws -> String
    
    /// 加载图片
    func loadImage(path: String) async throws -> UIImage?
    
    /// 删除图片
    func deleteImage(path: String) async throws
}

/// 数据持久化协议
public protocol DataPersistenceProvider {
    /// 保存主体数据
    func saveSubject(_ subject: RecognizedSubject) async throws
    
    /// 保存实体数据
    func saveEntity(_ entity: RecognizedEntity) async throws
    
    /// 查询主体
    func fetchSubjects(for entityId: String?) async throws -> [RecognizedSubject]
    
    /// 查询实体
    func fetchEntities() async throws -> [RecognizedEntity]
    
    /// 删除主体
    func deleteSubject(_ subjectId: String) async throws
    
    /// 删除实体
    func deleteEntity(_ entityId: String) async throws
}
