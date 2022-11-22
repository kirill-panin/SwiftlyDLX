# SwiftlyDLX

Swiftly DLX is an attempt at providing a simple but efficient Algorithm X method. If you are not familiar with Knuth's Dancing links algorithm I suggest you read his paper https://www.ocf.berkeley.edu/~jchu/publicportal/sudoku/0011047.pdf

Because of the memory management of swift I am not using a true implementation of swift but a variation which I have found works more efficiently in Swift. I hope to be able to find a way to implement this algorithm true to Knuth's idea. Knuth even mentions in his paper memory management might be an isssue with this method.

This is just for fun. Use at your own risk. 


The DLX model accepts a couple of different representations of exact cover grids however the most efficient representation is an array of Integers Sets. The Integers being the columns the row correlates to.

## Usage

Before going on to the examples you need to create a model applicable to your use case. I will use sudoku as an example however a multitude of use cases exist.

In sudoku the exact cover grid can view in such a way that the rows indicate the value and location of each possible value where the columns will be the rules applicable to each cell. Since there are 729 unique values that can be entered on sudoku (81 locations with 9 values each) 81*9=729. As such there are 4 rules which apply to each cell. Each cell is filled, each row is filled with 1-9 with no duplicates, each column is filled with 1-9 with no duplicates, and each box is filled with 1-9 with no duplicates. In this example all of these values can be mathematically derived.

Location and value can be derived from the exact cover row index (ri)

* value = ri%9
* index = ri/9
(additionally we can find the 2D coordinates and box index easily as well)
* x = index%9
* y = index/9
* b = (y/3)*3 + (x/3)

calculating the columns for a cells rules or constraints is pretty straight forward as well. 

All Cells are filled: (x*9) 
