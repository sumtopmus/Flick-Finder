//
//  FlickrAPI.swift
//  Flick Finder
//
//  Created by Oleksandr Iaroshenko on 09.06.15.
//  Copyright (c) 2015 Oleksandr Iaroshenko. All rights reserved.
//

import Foundation

class FlickrAPI {

    // Keys for Flickr API HTTP calls
    private struct HTTPKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let SafeSearch = "safe_search"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }

    // Flickr API Methods
    private struct Methods {
        static let GetPhotosFromGallery = "flickr.galleries.getPhotos"
        static let GetPhotos = "flickr.photos.search"
    }

    // Dictionary keys for JSON results
    private struct JSONKeys {
        static let Photos = "photos"
        static let PhotoArray = "photo"
        static let Title = "title"
        static let URL = "url_m"
    }

    // Magic values
    private struct Defaults {
        static let BaseURL = "https://api.flickr.com/services/rest/"
        static let APIKey = "b95f2030b0216710e7357e1b912cdb22"

        static let Connector = "?"
        static let Separator = "&"
        static let KeyValueEqualitySign = "="

        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJSONCallback = "1"

        static let GetPhotosParameters = [
            HTTPKeys.Method : Methods.GetPhotos,
            HTTPKeys.APIKey : Defaults.APIKey,
            HTTPKeys.SafeSearch : Defaults.SafeSearch,
            HTTPKeys.Extras : Defaults.Extras,
            HTTPKeys.Format : Defaults.Format,
            HTTPKeys.NoJSONCallback : Defaults.NoJSONCallback
        ]

        static let BoundingBoxHalfSize = 0.1
    }

    // MARK: - Access to Flickr API Calls

    class func searchPhotosByPhrase(phrase: String, completion: ((photos: [FlickrPhoto]) -> Void)?) {
        var parameters = Defaults.GetPhotosParameters
        parameters[HTTPKeys.Text] = phrase

        performRequest(parameters) { data in
            let photos = FlickrAPI.parsePhotosWithJSONData(data)
            completion?(photos: photos)
        }
    }

    class func searchPhotosByCoordinates(#latitude: Double, longitude: Double, completion: ((photos: [FlickrPhoto]) -> Void)?) {
        var parameters = Defaults.GetPhotosParameters
        parameters[HTTPKeys.BoundingBox] = constructBoundingBoxParameter(latitude: latitude, longitude: longitude)

        performRequest(parameters) { data in
            let photos = FlickrAPI.parsePhotosWithJSONData(data)
            completion?(photos: photos)
        }
    }

    private class func constructBoundingBoxParameter(#latitude: Double, longitude: Double) -> String {
        let boundingBoxCorners = ["\(longitude - Defaults.BoundingBoxHalfSize)", "\(latitude - Defaults.BoundingBoxHalfSize)", "\(longitude + Defaults.BoundingBoxHalfSize)", "\(latitude + Defaults.BoundingBoxHalfSize)"]

        return join(",", boundingBoxCorners)
    }

    // MARK: - HTTP Requests

    private class func performRequest(parameters: [String : String], completion: ((parsedJSONData: AnyObject?) -> Void)?) {
        let session = NSURLSession.sharedSession()

        let urlString = constructHTTPCall(parameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError?
                let parsedData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)

                completion?(parsedJSONData: parsedData)
            }
        }

        task.resume()
    }

    private class func constructHTTPCall(parameters: [String : String]) -> String {
        var result = Defaults.BaseURL
        result += parameters.isEmpty ? "" : "?"

        var parametersSet = [String]()
        for (key, value) in parameters {
            if let escapeEncodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                parametersSet.append(key + "=" + escapeEncodedValue)
            }
        }

        result += join("&", parametersSet)

        return result
    }

    // MARK: JSON Parsing

    private class func parsePhotosWithJSONData(data: AnyObject?) -> [FlickrPhoto] {
        var result = [FlickrPhoto]()

        if let dataDictionary = data as? [String : AnyObject],
            photos = dataDictionary[JSONKeys.Photos] as? [String : AnyObject],
            photoArray = photos[JSONKeys.PhotoArray] as? [[String : AnyObject]] {
            for photo in photoArray {
                if let title = photo[JSONKeys.Title] as? String,
                    url = photo[JSONKeys.URL] as? String {
                    result.append(FlickrPhoto(title: title, urlString: url))
                }
            }
        }

        return result
    }
}