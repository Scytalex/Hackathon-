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
    
        uint256 amountPerToken = msg.value.div(totalSupply); //calculamos la cantidad de USDC que tocaria por token

        address[] memory holders = getTokenHolders();
        for (uint256 i = 0; i < holders.length; i++) {
            address owner = holders[i];
            uint256 ownerBalance = balances[owner];
            uint256 ownerShare = amountPerToken.mul(ownerBalance);  // la candidad de USDC que le tocaria al owner segun la cantidad de tokens que posea
            payable(owner).transfer(ownerShare);                    // se paga a los owners.
        }
    }

    function withdraw() public onlyOwner {        //en esta funcion hacemos el pago a los holders
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    function getTokenHolders() internal view returns (address[] memory) {  //obtenemos la cantidad de holders
        uint256 holderCount = 0;                            //inicializamos el contador
        for (uint256 i = 0; i < balances.length; i++) {     //recorremos los balances
            if (balances[address(uint160(i))] > 0) {        //si en el balance se encuentra al menos un token 
                holderCount++;                              // se incrementa el contador
            }
        }

        address[] memory holders = new address[](holderCount);
        uint256 index = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            if (balances[address(uint160(i))] > 0) {
                holders[index] = address(uint160(i));
                index++;
            }
        }

        return holders;
    }
}
