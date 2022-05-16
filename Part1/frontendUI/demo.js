const { poseidonContract } = require("circomlibjs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { groth16 } = require("snarkjs");

var leafValue = 0;
var PoseidonT3, poseidonT3, MerkleTree;

async function initialize() {
    PoseidonT3 = await ethers.getContractFactory(
        poseidonContract.generateABI(2),
        poseidonContract.createCode(2)
    )
    poseidonT3 = await PoseidonT3.deploy();
    await poseidonT3.deployed();

    MerkleTree = await ethers.getContractFactory("MerkleTree", {
        libraries: {
            PoseidonT3: poseidonT3.address
        },
      });
    merkleTree = await MerkleTree.deploy();
    await merkleTree.deployed();
}


function unstringifyBigInts(o) {
    if ((typeof(o) == "string") && (/^[0-9]+$/.test(o) ))  {
        return BigInt(o);
    } else if ((typeof(o) == "string") && (/^0x[0-9a-fA-F]+$/.test(o) ))  {
        return BigInt(o);
    } else if (Array.isArray(o)) {
        return o.map(unstringifyBigInts);
    } else if (typeof o == "object") {
        if (o===null) return null;
        const res = {};
        const keys = Object.keys(o);
        keys.forEach( (k) => {
            res[k] = unstringifyBigInts(o[k]);
        });
        return res;
    } else {
        return o;
    }
}

function printTree() {
    document.getElementById("treeContents").innerText = merkleTree.hashes;
}

async function addLeaf() {
    await merkleTree.insertLeaf(leafValue++);
    printTree();
}

async function verify(){
    const node9 = (await merkleTree.hashes(9)).toString();
        const node13 = (await merkleTree.hashes(13)).toString();

        const Input = {
            "leaf": "1",
            "path_elements": ["2", node9, node13],
            "path_index": ["0", "0", "0"]
        }
        const { proof, publicSignals } = await groth16.fullProve(Input, "circuits/circuit_js/circuit.wasm","circuits/circuit_final.zkey");

        const editedPublicSignals = unstringifyBigInts(publicSignals);
        const editedProof = unstringifyBigInts(proof);
        const calldata = await groth16.exportSolidityCallData(editedProof, editedPublicSignals);
    
        const argv = calldata.replace(/["[\]\s]/g, "").split(',').map(x => BigInt(x).toString());
    
        const a = [argv[0], argv[1]];
        const b = [[argv[2], argv[3]], [argv[4], argv[5]]];
        const c = [argv[6], argv[7]];
        const input = argv.slice(8);
        const output = await merkleTree.verify(a, b, c, input);
        alert("Verification status : " + output);
}