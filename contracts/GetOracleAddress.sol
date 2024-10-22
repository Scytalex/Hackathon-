// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOraclize {
    function requestBytes32(string memory _path) external returns (bytes32);
}

contract GetOracleAddress {
    IOraclize public oracle;
    bytes32 public oracleData; // Variable para almacenar el dato del oráculo

   constructor(address _oracleAddress) {
        oracle = IOraclize(_oracleAddress);
    }

    function getOracleData() public view returns (bytes32) {
        return oracle.requestBytes32("http://api.trustlesswork.com"); // Reemplaza con la URL real del oráculo
    }
}
