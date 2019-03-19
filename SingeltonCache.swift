//
//  SingeltonCache.swift
//  VostBankLightFront
//
//  Created by Dmitry Gulyagin on 06/02/2019.
//  Copyright © 2019 VostBank. All rights reserved.
//

import Foundation

/**
 Данный класс позволяет создать уникальный для класса кеш.
 - important:
 В данном кеше может храниться только один экземпляр каждлого класса. Это значит что при сохранении нового экземпляра класса, старый будет перезаписан.
 - Author:
 Dmitry Gulyagin
 - Date:
 6.02.2019
 - Version:
 1.0
 */
class SingeltonCache {
    /// Возращает локальный URL для сохранение синглтона в кеш.
    private static func cachePath<T>(for objectType: T.Type) -> URL? {
        if let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileName = "StaticDataManager.\(objectType).cache"
            return directory.appendingPathComponent(fileName)
        } else {
            assertionFailure("Не удалось получить место размещения кеша для класса \(T.self)ю.")
            return nil
        }
    }
    
    /// Уникальный ключ для сохраняемого синглтона
    private static func cacheKeyForDate<T>(for objectType: T.Type) -> String {
        return "StaticDataManager.\(objectType).key"
    }

    private static func setSaveDate<T>(objectType: T.Type) {
        let key = cacheKeyForDate(for: objectType)
        UserDefaults.standard.set(Date(), forKey: key)
    }
    
    static func lastSaveDate<T>(objectType: T.Type) -> Date? {
        let key = cacheKeyForDate(for: objectType)
        return UserDefaults.standard.object(forKey: key) as? Date
    }
    
    /// Удаляет файл кеша.
    static func remove<T>(objectType: T.Type) {
        guard let path = cachePath(for: T.self) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: path)
        }
        catch {
            assertionFailure("Ошибка удаления кеша \(T.self). [ERROR]: \(error.localizedDescription)")
        }
    }
    
    /// Сохранает объект класса в кеш.
    static func save<T>(object: T) where T: Encodable {
        guard let path = cachePath(for: T.self) else {
            return
        }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            try data.write(to: path)
            setSaveDate(objectType: T.self)
        }
        catch {
            assertionFailure("Ошибка сохранения \(T.self) в кеш. [ERROR]: \(error.localizedDescription)")
        }
    }
    
    /// Возращает объект класса из кеша.
    static func load<T>(objectType: T.Type) -> T? where T: Decodable  {
        guard let path = cachePath(for: T.self) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: path)
            let object = try decoder.decode(objectType, from: data)
            return object
        }
        catch {
            return nil
        }
    }
}
