//
//  NetworkManager.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/6/25.
//

import Foundation
import Foundation



class NetworkManager: NSObject, URLSessionDelegate {
    

    func fetchFinalURL(from sourceURL: URL, completion: @escaping (URL?) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: sourceURL) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, let redirectedURL = httpResponse.url {
                completion(redirectedURL)
            } else {
                completion(nil)
            }
        }
        dataTask.resume()
    }
    

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
  
    static func isURLValid() async -> Bool {

        if let encodedURLString = Constants.urlForValidation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let finalURL = URL(string: encodedURLString) {
            
            let manager = NetworkManager()
            
            return await withCheckedContinuation { continuation in
                manager.fetchFinalURL(from: finalURL) { redirectedURL in
                    DispatchQueue.main.async {
                        if let finalHost = redirectedURL?.host {
                            continuation.resume(returning: finalHost.contains("google"))
                        } else {
                            continuation.resume(returning: false)
                        }
                    }
                }
            }
        } else {
            return false
        }
    }
}

// Функция обновления состояния с учётом проверки URL
//func refreshContent() {
//    if isUpdateNeeded {
//        // Отображаем экран загрузки
//        Task {
//            let isValid = await NetworkManager.isURLValid()
//            if !isValid {
//                currentVerse = 1
//                isUpdateNeeded = false
//                isLoading = false
//            } else {
//                currentVerse = 0
//                isUpdateNeeded = false
//                isLoading = false
//            }
//        }
//    } else {
//        isLoading = false
//    }
//}
