# SwiftlyDLX

Swiftly DLX is an attempt at providing a simple but efficient Algorithm X method. If you are not familiar with Knuth's Dancing links algorithm I suggest you read his paper https://www.ocf.berkeley.edu/~jchu/publicportal/sudoku/0011047.pdf

Because of the memory management of swift I am not using a true implementation of swift but a variation which I have found works more efficiently in Swift. I hope to be able to find a way to implement this algorithm true to Knuth's idea. Knuth even mentions in his paper memory management might be an isssue with this method.

This is just for fun. Use at your own risk. 


The DLX model accepts a couple of different representations of exact cover grids however the most efficient representation is an array of Integers Sets. The Integers being the columns the row correlates to.

## Example

This example will be using DLX to check if a sudoku puzzle has only one solution.

To use this will sudoku First I will need to define how sudoku works. Luckily this is relatively straight forward. 

#### Convert all possible location/value pairs to a numeric value.

I will use a single dimension array to represent the sudoku board for simplicity but the same concept can be applied to a 2D array as well. 

```swift
let DLXRowIndex = index * 9 + value
```
