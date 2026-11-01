import Foundation

// #region agent log
func persistAgentLog(_ payload: [String: Any]) {
    guard let json = try? JSONSerialization.data(withJSONObject: payload),
          var line = String(data: json, encoding: .utf8) else { return }
    line += "\n"
    let hostHome = ProcessInfo.processInfo.environment["SIMULATOR_HOST_HOME"] ?? "/Users/dhruvjha"
    let url = URL(fileURLWithPath: hostHome + "/.cursor/debug-logs/debug-3986be.log")
    if FileManager.default.fileExists(atPath: url.path),
       let handle = try? FileHandle(forWritingTo: url) {
        defer { try? handle.close() }
        handle.seekToEndOfFile()
        handle.write(Data(line.utf8))
    } else {
        try? line.write(to: url, atomically: true, encoding: .utf8)
    }
    var req = URLRequest(url: URL(string: "http://127.0.0.1:7830/ingest/ba1511e5-5bf2-4028-8a5e-914c728d2b60")!)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("3986be", forHTTPHeaderField: "X-Debug-Session-Id")
    req.httpBody = json
    URLSession.shared.dataTask(with: req).resume()
}
// #endregion
