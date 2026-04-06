import Foundation

struct JSONFileStore {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func load<T: Decodable>(_ type: T.Type, filename: String) throws -> T {
        let url = try fileURL(for: filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            if let emptyArrayType = [] as? T {
                return emptyArrayType
            }
            throw CocoaError(.fileNoSuchFile)
        }

        let data = try Data(contentsOf: url)

        if data.isEmpty, let emptyArrayType = [] as? T {
            return emptyArrayType
        }

        return try decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, filename: String) throws {
        let url = try fileURL(for: filename)
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private func fileURL(for filename: String) throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupport
            .appendingPathComponent(AppConstants.appDirectoryName, isDirectory: true)
            .appendingPathComponent(filename, isDirectory: false)
    }
}
