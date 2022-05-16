//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        hashes = new uint256[](15);
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i=0; i < 8; i++) {
            hashes[i] = 0; 
        }
    }

    function calculateMHT() internal {
        uint256 k = 0;
        for (uint256 i = 8 ; i < 15; i++) {
            uint256 leftHash = hashes[k];
            k = k+1;
            uint256 righttHash = hashes[k];
            k = k+1;
            hashes[i] = PoseidonT3.poseidon([leftHash, righttHash]); 
        }
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        index = index + 1;

        //recalculate MHT
        calculateMHT();
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
