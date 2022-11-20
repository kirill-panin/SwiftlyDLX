import XCTest
@testable import SwiftlyDLX

enum TestError : Error {
    case runtime(String)
}
final class SwiftlyDLXTests: XCTestCase {
    
    
    func testExample() throws {
        let g = CreateSudokuDLX()
        var dlx = SDLX(exactCover: g)
        var count = 0
        dlx.generate{solution in
            count += 1
            print("Solution #\(count)")
            PrintSolutionAsPuzzle(solution)
            return count == 3 ? solution:nil
        }
        XCTAssertEqual(SwiftlyDLX().text, "Hello, World!")
    }
}
func PrintSolutionAsPuzzle(_ solution: Set<Int>) {
    let p = ConvertSolutionToPuzzle(solution)
    let pl : (Int)->() = {
        let n = $0*9
        print("\(p[n])|\(p[n+1])|\(p[n+2])||\(p[n+3])|\(p[n+4])|\(p[n+5])||\(p[n+6])|\(p[n+7])|\(p[n+8])")
    }
    pl(0)
    pl(1)
    pl(2)
    print([String](repeating: "_", count: 19).joined(separator: ""))
    pl(3)
    pl(4)
    pl(5)
    print([String](repeating: "_", count: 19).joined(separator: ""))
    pl(6)
    pl(7)
    pl(8)
}
func ConvertSolutionToPuzzle(_ solution: Set<Int>) -> [Int] {
    var p = [Int](repeating: 0, count: 81)
    for i in solution {
        
        let value = (i%9)+1
        let index = i/9
        p[index] = value
    }
    return p
}
func CreateSudokuDLX() -> [Set<Int>] {
    return (0..<729).map{
        let value = $0%9
        let index = $0/9
        let row = index/9
        let column = index%9
        let box = (row/3)*3 + (column/3)
        return [
            (row*9)+column,       //All spaces filed
            (row*9)+value+81,     //All cell values in row are unique to that row
            (column*9)+value+162, //All cell values in a column are unique to that column
            (box*9)+value+243     //All cell values in a box are unique to that box
        ]
    }
}
