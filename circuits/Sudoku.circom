pragma circom 2.0.0;

include "./circomlib/circuits/comparators.circom";

//------------------------------------
// The proof works base of the fact (can be proved by contradiction and pigeon-hole principle) that
// for k = 9, n > 0
//
// Let X = {x_1, x_2, ..., x_k} is a multiset
// where for 1 <= i <= k ,  n <= x_i <= n + k
//
// Let
// S(X) = Sigma(x_i| i in [1, k]), 
// P(X) = Product(x_i | i in [1,k])
//
// for two X sets, X1, X2,
// if S(X1) == S(X2) and P(X1) == P(X2) then X1 and X2 are permutations of each other.
//------------------------------------

template SudokuTemplate(size) {

    // Statement
    signal input problem[size][size];

    // witness
    signal input solution[size][size];

    component lessThan[size][size];
    component greaterThan[size][size];

    signal checkHorizontalSums[size];
    signal checkVerticalSums[size];
    signal checkSquareSums[size];

    signal checkHorizontalMuls[size];
    signal checkVerticalMuls[size];
    signal checkSquareMuls[size];

    for(var i = 0; i < size; i++){
        var currentSum = 0;
        var currentMul = 1;
        for(var j = 0; j < size; j++){
            
            // checking the problem and solution match
            0 === problem[i][j] * (solution[i][j] - problem[i][j]);
    
            // Checking the solution values are less than 10
            lessThan[i][j] = LessThan(4);
            lessThan[i][j].in[0] <== solution[i][j];
            lessThan[i][j].in[1] <== 10;
            lessThan[i][j].out === 1;

            // Checking the solution values are greater than 0
            greaterThan[i][j] = GreaterThan(4);
            greaterThan[i][j].in[0] <== solution[i][j];
            greaterThan[i][j].in[1] <== 0;
            greaterThan[i][j].out === 1;

            currentSum += solution[i][j];
            currentMul *= solution[i][j];

        }

        // checking the horizontal lines
        checkHorizontalSums[i] <-- currentSum;
        checkHorizontalSums[i] === 45;
        checkHorizontalMuls[i] <-- currentMul;
        checkHorizontalMuls[i] === 362880;
    }


    // checking the vertical summation
    for(var i = 0; i < size; i++){
        var currentSum = 0;
        var currentMul = 1;
        for(var j = 0; j < size; j++){
            currentSum += solution[j][i];
            currentMul *= solution[j][i];
        }
        checkVerticalSums[i] <-- currentSum;
        checkVerticalSums[i] === 45;

        checkVerticalMuls[i] <-- currentMul;
        checkVerticalMuls[i] === 362880;
    }

    // checking the squares
    for(var i = 0; i < size; i++){
        var currentSum = 0;
        var currentMul = 1;
        for(var j = 0; j < size; j++){
            var iOff = (i \ 3) * 3;
            var jOff = (i % 3) * 3;
            var iIndex = j \ 3; 
            var jIndex =  j % 3;
            currentSum += solution[iOff + iIndex][jOff + jIndex];
            currentMul *= solution[iOff + iIndex][jOff + jIndex];
        }
        checkSquareSums[i] <-- currentSum;
        checkSquareSums[i] === 45;

        checkSquareMuls[i] <-- currentMul;
        checkSquareMuls[i] === 362880;
    }

}


component main {public [problem]} =  SudokuTemplate(9);
