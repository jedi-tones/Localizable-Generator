import Foundation

struct LocalizedModel {
    let key: String
    let value: String
}

enum ParseError: Error {
    case failParse
}

func parser(_ csv: String) throws -> [String: [LocalizedModel]] {
    let rows = csv.split(separator: "\r\n")
    guard rows.isEmpty == false,
    let firstRow = rows.first else {
        throw ParseError.failParse
    }
    let languages = firstRow
        .split(separator: ",")
        .filter { $0.contains("ios") == false }
        .dropFirst()
    
    guard languages.isEmpty == false else {
        throw ParseError.failParse
    }
    var localizables = [String: [LocalizedModel]]()
    localizables.reserveCapacity(rows.count - 1)
    
    languages.forEach { subs in
        localizables[String(subs.lowercased())] = []
    }
    rows[1...].forEach { subs in
        let row = subs.enumerated().split { (index, character) in
            let nextIndex = subs.index(subs.startIndex, offsetBy: index + 1)
            if subs.indices.contains(nextIndex) {
                let nextString = subs[nextIndex]
                if character == "," {
                    return nextString != " "
                }
            }
            return false
        }.map { element in
            String(element.map { $0.element }).replacingOccurrences(of: "\"", with: "")
        }
        guard row.isEmpty == false else {
            return
        }
        let key = row[0]
        languages
            .enumerated()
            .forEach { (index, lang) in
                let valueIndex = index + 1
                if row.indices.contains(valueIndex) {
                    let model = LocalizedModel(key: String(key), value: String(row[valueIndex]))
                    localizables[String(lang).lowercased()]?.append(model)
                }
            }
    }
    return localizables
}
