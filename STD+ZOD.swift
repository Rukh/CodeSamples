//
//  StaticDataManager+ZOD.swift
//  VostBankLightFront
//
//  Created by Dmitry Gulyagin on 06/02/2019.
//  Copyright © 2019 VostBank. All rights reserved.
//

import Foundation

// Полностью повторяет структуру ответа сервера на запрос getZODResponse
struct GetZODResponse: Decodable {
    struct ZODParameters: Decodable {
        let status: String
        let dateStart: String
        let dateEnd: String
    }
    let getZODResponse: ZODParameters
}

extension StaticDataManager.Dictionary {
    /// Хранит время начала и окончания ЗОД
    struct ZOD: Codable {
        let startDate: Date
        let endDate: Date
        
        /// Инициализируует объект при помощи json-а приходяящего с сервера
        init?(serverResponse: GetZODResponse) {
            guard serverResponse.getZODResponse.status == "SUCCESS" else {
                return nil
            }
            
            let startDateString = serverResponse.getZODResponse.dateStart
            let endDateString = serverResponse.getZODResponse.dateEnd
            
            // Часовой пояс новосибирска GMT+7
            let timeZone = TimeZone(secondsFromGMT: 7 * 60 * 60)
            
            let firstFormater = DateFormatter()
            firstFormater.dateFormat = "yyyy-MM-dd' 'HH:mm:ss.S"
            firstFormater.timeZone = timeZone
            let secondFormater = DateFormatter()
            secondFormater.timeZone = timeZone
            secondFormater.dateFormat = "HH:mm:ss"
            
            if let startDate = firstFormater.date(from: startDateString) {
                self.startDate = startDate
            } else if let startDate = secondFormater.date(from: startDateString) {
                self.startDate = startDate
            } else {
                return nil
            }
            
            if let endDate = firstFormater.date(from: endDateString) {
                self.endDate = endDate
            } else if let endDate = secondFormater.date(from: endDateString) {
                self.endDate = endDate
            } else {
                return nil
            }
        }
    }
}
