public class SudokuSolver {
    private var dlx: SDLX? = nil

    public init() {
        self.dlx = SDLX(exactCover: createSudokuDLX());
    }

    private func createSudokuDLX() -> [Set<Int>] {
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

    public func solve(puzzle: [[Int]]) -> [[Int]] {
        let set = twoDimensionalToSet(matrix: puzzle)
        if let solution = dlx?.solve(set) {
            let converted = convertSolutionToPuzzle(solution)
            return arrayToTwoDimensionalArray(array: converted)
        }
        return []
    }

    private func twoDimensionalToSet(matrix: [[Int]]) -> Set<Int> {
        let array = matrix.flatMap { $0 }
        return Set(array.enumerated().filter {(i, v) in return v > 0}.map { $0 * 9 + ($1 - 1)})
    }

    private func setToTwoDimensionalArray(set: Set<Int>) -> [[Int]] {
        var matrix: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for i in 0..<9 {
            for j in 0..<9 {
                matrix[i][j] = set[set.index(set.startIndex, offsetBy: i * 9 + j)] 
            }
        }
        return matrix
    }

    private func arrayToTwoDimensionalArray(array: [Int]) -> [[Int]] {
        var matrix: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for i in 0..<9 {
            for j in 0..<9 {
                matrix[i][j] = array[i * 9 + j] 
            }
        }
        return matrix
    }

    public func isOnlyOneSolution(puzzle: [[Int]]) -> Bool {
        if let solutions = dlx?.attempt(rows: twoDimensionalToSet(matrix: puzzle), 2) {
            return solutions.count == 1
        }
        return false
    }

    private func convertSolutionToPuzzle(_ solution: Set<Int>) -> [Int] {
        var p = [Int](repeating: 0, count: 81)
        for i in solution {
                let value = (i%9)+1
                let index = i/9
                p[index] = value
        }
        return p
    }
}