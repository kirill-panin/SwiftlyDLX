# SwiftlyDLX

Swiftly DLX is an attempt at providing a simple but efficient Algorithm X method. If you are not familiar with Knuth's Dancing links algorithm I suggest you read his paper https://www.ocf.berkeley.edu/~jchu/publicportal/sudoku/0011047.pdf

Because of the memory management of swift I am not using a true implementation of swift but a variation which I have found works more efficiently in Swift. I hope to be able to find a way to implement this algorithm true to Knuth's idea. Knuth even mentions in his paper memory management might be an isssue with this method.

This is just for fun. Use at your own risk. 


The DLX model accepts a couple of different representations of exact cover grids however the most efficient representation is an array of Integers Sets. The Integers being the columns the row correlates to.

## Example

This example will be using DLX to find the solution to a puzzle.

To use this will sudoku First I will need to define how sudoku works. Luckily this is relatively straight forward. 

#### Convert all possible location/value pairs to a numeric value.

I will use a single dimension array to represent the sudoku board for simplicity but the same concept can be applied to a 2D array as well. 

```swift
let DLXRowIndex = index * 9 + value - 1 //0 is the initial value
```

and to get the location / value pair from this value

```swift
let value = (DLXRowIndex % 9) + 1
let index =  DLXRowIndex / 9
```

#### Define the rules or constraints of sudoku. 

There are 4 rules to sudoku

1. Every cell must be filled.
2. Each row must contain only 1 of each value between 1-9.
3. Each column must contain only 1 of each value between 1-9.
4. Each box must contain only 1 of each value between 1-9.

Each location/value pair's compliance to these rules can be defined using 4 equations. however to get that we need to derive (row, column, box) indices from the puzzle index. We will also need the value before its corrected for human readability. 

```swift
let value = DLXRowIndex % 9 //0-8
let index = DLXRowIndex / 9 //0-80
let row = index / 9 //0-8
let column = index % 9 //0-8
let box = (row/3)*3 + (column/3) //0-8

let allFilled = row * 9 + column
let rowsFilled = row * 9 + value
let columnsFilled = column * 9 + value
let boxFilled = box * 9 + value

```

#### Putting it all together. Now that all of the component parts are worked out the Exact cover grid can be represented in a series of sets within an array.

```swift
var XCoverGrid : [Set<Int>] = []
for i in 0..<729 { //81*9
    let value = i%9
    let index = i/9
    let row = index/9
    let column = index % 9
    let box = (row/3)*3 + (column/3)
    
    XCoverGrid.append([
        row * 9 + column,
        row * 9 + value + 81, //offset so no duplicate values are possible
        column * 9 + value + 162,
        box * 9 + value + 243
    ])
}

var dlx = SDLX(exactCover: XCoverGrid)
```

Like that the rules of sudoku have been defined as an exact cover board now I just need a puzzle to apply to this.

For sake of example I will use the "World hardest sudoku Puzzle" found on https://abcnews.go.com/blogs/headlines/2012/06/can-you-solve-the-hardest-ever-sudoku

```swift
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
```

Convert this puzzle into a set of DLXRowIndices. and solve

```swift
let rs = Set(PUZZLE.enumerated().filter{(_,v) in v>0}.map{$0*81+($1-1)})
guard let solution = dlx.solve(rs) else {return}//probably want error handling

```

Now convert the solution back to a readable representation

```swift
var puzzle = [Int](repeating:0, count:81)
for i in solution {
let value = (i%9) + 1
let index = i/9
puzzle[index] = value
}
```
|     |     |     |     |     |     |     |     |     |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 8 | 6 | 9 | 7 | 1 | 2 | 3 | 4 | 5 |
| 4 | 2 | 3 | 6 | 5 | 8 | 9 | 7 | 1 |
| 1 | 7 | 5 | 4 | 9 | 3 | 2 | 8 | 6 |
| 9 | 5 | 6 | 8 | 3 | 7 | 1 | 2 | 4 |
| 7 | 8 | 4 | 1 | 2 | 6 | 7 | 6 | 8 |
| 2 | 3 | 1 | 9 | 4 | 5 | 7 | 6 | 8 |
| 3 | 4 | 8 | 5 | 7 | 9 | 6 | 1 | 2 |
| 6 | 9 | 2 | 3 | 8 | 1 | 4 | 5 | 7 |
| 5 | 1 | 7 | 2 | 6 | 4 | 8 | 9 | 3 |

9|5|6||8|3|7||1|2|4
7|8|4||1|2|6||5|3|9
2|3|1||9|4|5||7|6|8
___________________
3|4|8||5|7|9||6|1|2
6|9|2||3|8|1||4|5|7
5|1|7||2|6|4||8|9|3



