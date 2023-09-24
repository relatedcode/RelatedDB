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
class RDRuntime {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func allClasses() -> [AnyClass] {

		let numberOfClasses = Int(objc_getClassList(nil, 0))
		if numberOfClasses > 0 {
			let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
			let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
			let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
			assert(numberOfClasses == count)
			defer { classesPtr.deallocate() }
			let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
			return classes
		}
		return []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func subclasses(of `class`: AnyClass) -> [AnyClass] {

		return self.allClasses().filter {
			var ancestor: AnyClass? = $0
			while let type = ancestor {
				if ObjectIdentifier(type) == ObjectIdentifier(`class`) { return true }
				ancestor = class_getSuperclass(type)
			}
			return false
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func classes(conformToProtocol `protocol`: Protocol) -> [AnyClass] {

		let classes = self.allClasses().filter { aClass in
			var subject: AnyClass? = aClass
			while let aClass = subject {
				if class_conformsToProtocol(aClass, `protocol`) { return true }
				subject = class_getSuperclass(aClass)
			}
			return false
		}
		return classes
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func classes<T>(conformTo: T.Type) -> [AnyClass] {

		return self.allClasses().filter { $0 is T }
	}
}
