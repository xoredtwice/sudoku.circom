#!/bin/sh

echo "Cleaning up"

rm -r build/
mkdir build/
cd build/

echo "Compiling Sudoku circuit"
circom ../circuits/Sudoku.circom --r1cs --wasm
node Sudoku_js/generate_witness.js Sudoku_js/Sudoku.wasm ../data/correctSolution.json SudokuWitness.wtns

echo "Ceremory Phase 1"
snarkjs powersoftau new bn128 12 pot12_0000.ptau 
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution"

echo "Ceremony Phase 2"
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau 
snarkjs groth16 setup Sudoku.r1cs pot12_final.ptau Sudoku_0000.zkey
snarkjs zkey contribute Sudoku_0000.zkey Sudoku_0001.zkey --name="First contribution" 
snarkjs zkey export verificationkey Sudoku_0001.zkey verification_key.json

snarkjs groth16 prove Sudoku_0001.zkey SudokuWitness.wtns proof.json public.json
