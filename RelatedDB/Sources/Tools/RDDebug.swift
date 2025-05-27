//
// Copyright (c) 2025 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SQLite3

//-----------------------------------------------------------------------------------------------------------------------------------------------
public enum RDDebugLevel {

	case none
	case error
	case all
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class RDDebug: NSObject {

	private var debugLevel: RDDebugLevel = .all

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RDDebug = {
		let instance = RDDebug()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func level(_ debugLevel: RDDebugLevel) {

		shared.debugLevel = debugLevel
	}
}

// MARK: - Debug methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func info(_ message: String) {

		print_info(message)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ message: String) {

		print_error(message)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ error: Error) {

		print_error(error.localizedDescription)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ error: Error?) {

		if let error = error {
			print_error(error.localizedDescription)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ handle: OpaquePointer?) {

		if let handle = handle {
			let desc = convert(sqlite3_errmsg(handle))
			let code = Int(sqlite3_errcode(handle))
			print_error("\(desc) - \(code)")
		} else {
			print_error("Database is not open.")
		}
	}
}

// MARK: - Print methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func print_info(_ message: String) {

		RDLogger.info(message)
		if (shared.debugLevel == .all) {
			print("RDB: " + message.trimmingCharacters(in: .newlines))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func print_error(_ message: String) {

		RDLogger.error(message)
		if (shared.debugLevel != .none) {
			print("RDB Error: \(message)")
		}
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func convert(_ value: UnsafePointer<Int8>?) -> String {

		if let value = value {
			return String(cString: value)
		}
		return ""
	}
}

// MARK: - Thread methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RDDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func thread() {

		let main = Thread.isMainThread ? "main" : "background"
		let temp = __dispatch_queue_get_label(nil)
		let name = String(cString: temp, encoding: .utf8) ?? "no name"
		print("Thread: \(main) - \(name)")
	}
}
