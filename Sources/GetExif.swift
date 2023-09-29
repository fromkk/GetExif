// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreImage
import ArgumentParser
import AppKit

enum GetExifError: Error {
    case pathNotFound
    case imageGetFailed
}

@main
struct GetExif: ParsableCommand {
    @Argument(help: "path for jpeg")
    var path: String

    func run() throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            throw GetExifError.pathNotFound
        }

        let url = URL(fileURLWithPath: path)
        guard let image = CIImage(contentsOf: url) else {
            throw GetExifError.imageGetFailed
        }

        let properties: [String: Any] = image.properties
        var result = [String]()

        if let tiff = properties["{TIFF}"] as? [String: Any] {
            var models: [String] = []
            if let model = tiff["Model"] as? String {
                models.append(model)
            }
            if let maker = tiff["Make"] as? String {
                models.append(maker)
            }
            result.append(models.joined(separator: " "))
        }

        if let exif = properties["{Exif}"] as? [String: Any] {
            if let lens = exif["LensModel"] as? String {
                result.append(lens)
            }
            var status: [String] = []
            if let focalLength = exif["FocalLength"] as? Int {
                status.append("\(focalLength)mm")
            }
            if let fNumber = exif["FNumber"] as? Double {
                status.append("f/\(fNumber)")
            }
            if let exposureTime = exif["ExposureTime"] as? Double {
                if exposureTime > 1 {
                    status.append("\(exposureTime.description)s")
                }
                else {
                    status.append("1/\(Int(1 / exposureTime).description)s")
                }
            }
            if let isos = exif["ISOSpeedRatings"] as? [Int], let iso = isos.first {
                status.append("ISO\(iso)")
            }
            result.append(status.joined(separator: " "))
        }
        let resultString = result.joined(separator: "\n")
        NSPasteboard.general.setString(resultString, forType: .string)
        print(resultString)
    }
}
