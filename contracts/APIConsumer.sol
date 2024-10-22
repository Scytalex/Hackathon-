// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Direcciones para operar en TrustlessWork
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    // Almacenar la respuesta de la API
    string public apiResponse;

    constructor() {
        // Establecer la dirección del contrato Oracle
        setPublicChainlinkToken();
        oracle = 0xTrustlessWorkOracleAddress; // Cambiar a la dirección del Oracle de TrustlessWork
        jobId = "b7282d3d6b5b45a991d9a02875f11354"; // Job ID para hacer una llamada HTTP POST
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    // Función para iniciar la solicitud POST
    function requestAPIResponse(string memory postData) public returns (bytes32 requestId) {
        string memory url = "http://api.trustlesswork.com"; // URL de la API de TrustlessWork
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Establecer el URL y los datos para la solicitud POST
        req.add("post", url); // El endpoint de la API
        req.add("requestType", "POST"); // Tipo de solicitud
        req.add("body", postData); // Datos del cuerpo en formato JSON o como requiera la API

        // Hacer la solicitud
        return sendChainlinkRequestTo(oracle, req, fee);
    }

    // Función para recibir la respuesta de la API
    function fulfill(bytes32 _requestId, string memory _response) public recordChainlinkFulfillment(_requestId) {
        apiResponse = _response;
    }
}
