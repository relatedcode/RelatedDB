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
class RDSchemas: NSObject {

	private var schemas: [String: RDSchema] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RDSchemas = {
		let instance = RDSchemas()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ table: String) -> RDSchema {

		if let schema = shared.schemas[table] {
			return schema
		}

		fatalError("Trying to fetch a non-existing Schema. \(table)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ otype: RDObject.Type) -> RDSchema {

		let table = otype.table()

		if let schema = shared.schemas[table] {
			return schema
		}

		let schema = RDSchema(otype)
		shared.schemas[table] = schema
		return schema
	}
}
