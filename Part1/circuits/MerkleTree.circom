pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    signal internalNodes[2**n - 1];

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    // for bottom most level of internal nodes, calculate value from leaves
    component hashFunctionComponent = Poseidon(2);
    for (var i = 0; i < 2**(n-1) ; i++) {
        hashFunctionComponent.inputs[0] <== leaves[i];
        hashFunctionComponent.inputs[1] <== leaves[i+1];
        internalNodes[i] <== hashFunctionComponent.out;
    }

    // for subsequent level of internal nodes, calculate value from child internal nodes
    for (var j = 2**(n-1) ; j < ( 2**n-1 ) ; j++ ){
        hashFunctionComponent.inputs[0] <== internalNodes[j/2];
        hashFunctionComponent.inputs[1] <== internalNodes[(j/2)+1];
        internalNodes[j] <== hashFunctionComponent.out;
    }

    root <== internalNodes[2**n - 1];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashFunctionComponent[n]; 


    signal outputSignals[n+1];
    outputSignals[0] <== leaf;
    for ( var i = 0; i < n ; i++) {
        hashFunctionComponent[i] = Poseidon(2);
        hashFunctionComponent[i].inputs[0] <== path_index[i]*(path_elements[i] - outputSignals[i]) + outputSignals[i];
        hashFunctionComponent[i].inputs[1] <== path_index[i]*(outputSignals[i] - path_elements[i] ) + path_elements[i];
        outputSignals[i+1] <== hashFunctionComponent[i].out;
    }

    root <== outputSignals[n];
}