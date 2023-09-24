//
// Copyright (c) 2023 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class RDLogger: NSObject {

	private var key: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RDLogger = {
		let instance = RDLogger()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func key(_ value: String?) {

		shared.key = value
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDLogger {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func send(_ object: Any) {

		guard let key = shared.key else { return }

		if let data = try? JSONSerialization.data(withJSONObject: object) {
			if let text = String(data: data, encoding: .utf8) {
				send(key, "WARN", text)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func debug(_ text: String) { send("DEBUG", text)	}
	class func info(_ text: String)	 { send("INFO", text)	}
	class func warn(_ text: String)	 { send("WARN", text)	}
	class func error(_ text: String) { send("ERROR", text)	}
	class func fatal(_ text: String) { send("FATAL", text)	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDLogger {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func send(_ level: String, _ text: String) {

		if let key = shared.key {
			send(key, level, text)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func send(_ key: String, _ level: String, _ text: String) {

		let app = "SDK"
		let host = "RelatedDB"

		let time = Date().timeIntervalSince1970

		let line: [String: Any] = ["timestamp": time, "app": app, "level": level, "line": text]
		let body: [String: Any] = ["lines": [line]]

		var headers = ["Accept": "application/json", "Content-Type": "application/json"]

		if let data = key.data(using: .utf8) {
			let base64 = data.base64EncodedString()
			headers["Authorization"] = "Basic \(base64)"
		}

		let link = "https://logs.logdna.com/logs/ingest?hostname=\(host)&now=\(time)"

		var request = URLRequest(url: URL(string: link)!)
		request.allHTTPHeaderFields = headers
		request.httpMethod = "POST"
		request.httpBody = convert(body)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
			}
		}

		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func convert(_ dictionary: [String: Any]) -> Data {

		if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
			return data
		}
		fatalError("JSONSerialization error. \(dictionary)")
	}
}
