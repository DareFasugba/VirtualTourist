//
//  FlickrApiClient.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 15/04/2023.
//
import Foundation

class FlickrApiClient {
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        static let apiKey = "d6efeb3f480734ebdc490aea37d2e21a"
        static let secret = "58df3c15ce6831bf"
        
        case grabPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .grabPhotos(let latitude, let longitude, let page):
                return Endpoints.base + "?method=flickr.photos.search" + "&extras=url_m" + "&api_key=\(Endpoints.apiKey)" + "&accuracy=16" + "&lat=\(latitude)" +
                "&lon=\(longitude)" + "&per_page=20" + "&page=\(Int.random(in: 1...10))" + "&format=json&nojsoncallback=1"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
   
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
           
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }

 
    class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (FlickrResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.grabPhotos(latitude, longitude, page).url, responseType: FlickrResponse.self) { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response, nil)
                    }
            } else {
                completion(nil, error)
                print("Error!")
            }
        }
    }
}
