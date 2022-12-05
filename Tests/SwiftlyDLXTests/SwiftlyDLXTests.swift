import XCTest
@testable import SwiftlyDLX

enum TestError : Error {
    case runtime(String)
}
final class SwiftlyDLXTests: XCTestCase {
    
    
    func testExample() throws {
        let g = CreateSudokuDLX()
        var dlx = SDLX(exactCover: g)
        print(dlx.grid.columns.count)
        let HARDEST: [Int] = [
            3,6,0,0,0,0,5,0,0,
            0,0,0,0,0,1,0,4,0,
            0,0,0,0,0,0,0,0,0,
            0,0,3,0,7,0,8,0,0,
            2,0,4,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,0,
            0,0,0,3,0,0,0,1,0,
            0,7,0,0,0,0,0,0,2,
            0,0,0,9,5,0,0,0,0
        ]
        let PUZZLE: [Int] = [
        8,0,0,0,0,0,0,0,0,
        0,0,3,6,0,0,0,0,0,
        0,7,0,0,9,0,2,0,0,
        0,5,0,0,0,7,0,0,0,
        0,0,0,1,0,0,0,3,0,
        0,0,1,0,0,0,0,6,8,
        0,0,8,5,0,0,0,1,0,
        0,9,0,0,0,0,4,0,0,
        ]
        let rs = Set(HARDEST.enumerated().filter{(i, v) in return v>0}.map{$0*9+($1-1)})
        guard let solution = dlx.solve(rs) else {throw TestError.runtime("Unable to solve this puzzle")}
        print(dlx.grid.columns.count)
        PrintSolutionAsPuzzle(solution)
        print(dlx.history.count, solution.count)
        
        guard let simp = try dlx.simplify(solution, 20) else {throw TestError.runtime("Unable to simplify to expected size")}
        
        PrintSolutionAsPuzzle(simp)
        XCTAssertEqual(SwiftlyDLX().text, "Hello, World!")
    }
}
func ps(_ v: Int) -> String {
    return v == 0 ? " ":"\(v)"
}
func PrintSolutionAsPuzzle(_ solution: Set<Int>) {
    let p = ConvertSolutionToPuzzle(solution)
    let pl : (Int)->() = {
        let n = $0*9
        print("\(ps(p[n]))|\(ps(p[n+1]))|\(ps(p[n+2]))||\(ps(p[n+3]))|\(ps(p[n+4]))|\(ps(p[n+5]))||\(ps(p[n+6]))|\(ps(p[n+7]))|\(ps(p[n+8]))")
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
