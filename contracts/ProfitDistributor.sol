// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProfitDistributor is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    uint256 public profit; // Variable para almacenar las ganancias
    address private oracle; // Dirección del oráculo de Chainlink
    bytes32 private jobId; // ID del trabajo de Chainlink
    uint256 private fee; // Tarifa de Chainlink
    uint256 public totalSupply; // Asegúrate de definir totalSupply
    mapping(address => uint256) public balances; // Definición del mapeo de balances
    address[] public tokenHolders; // Array para almacenar los titulares de tokens

    constructor() {
        setPublicChainlinkToken();
        oracle = 0xYourOracleAddress; // Reemplaza con la dirección del oráculo de Chainlink
        jobId = "YourJobId"; // Reemplaza con el Job ID de Chainlink
        fee = 0.1 * 10 ** 18; // Tarifa en LINK (ajusta según sea necesario)
    }

    // Función para solicitar ganancias a la API de Trustless Work
    function requestProfit() public {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.add("get", "https://api.trustlesswork.com/your-endpoint"); // Reemplaza con la URL de la API
        req.add("path", "data.profit"); // Ajusta según la estructura de la respuesta de la API
        sendChainlinkRequestTo(oracle, req, fee);
    }

    // Función que se llama cuando se recibe la respuesta del oráculo
    function fulfill(bytes32 _requestId, uint256 _profit) public recordChainlinkFulfillment(_requestId) {
        profit = _profit; // Almacena las ganancias recibidas
    }

    // Función para distribuir las ganancias
    function distributeProfits() public payable {
        require(totalSupply > 0, "Total supply must be greater than zero"); // Verificación de totalSupply
        uint256 amountPerToken = msg.value / totalSupply; // calculamos la cantidad de USDC que tocaria por token

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            address owner = tokenHolders[i];
            uint256 ownerBalance = balances[owner];
            uint256 ownerShare = amountPerToken * ownerBalance;  // la cantidad de USDC que le tocaria al owner segun la cantidad de tokens que posea
            (bool success, ) = payable(owner).call{value: ownerShare}(""); // se paga a los owners de forma segura
            require(success, "Transfer failed"); // Verificación de la transferencia
        }
    }

    function withdraw() public onlyOwner {        //en esta funcion hacemos el pago a los holders
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    function getTokenHolders() internal view returns (address[] memory) {
        return tokenHolders; // Retorna el array de titulares de tokens
    }
}
