public class SudokuSolver {
    private var dlx: SDLX? = nil

    init() {
        self.dlx = SDLX(exactCover: createSudokuDLX());
    }

    func createSudokuDLX() -> [Set<Int>] {
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

    func solve(puzzle: [[Int]]) -> [[Int]] {
        let set = twoDimensionalToSet(matrix: puzzle)
        if let solution = dlx?.solve(set) {
            return setToTwoDimensionalArray(set: solution)
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

    func isOnlyOneSolution(puzzle: [[Int]]) -> Bool {
        if let solutions = dlx?.attempt(rows: twoDimensionalToSet(matrix: puzzle), 2) {
            return solutions.count == 1
        }
        return false
    }
}