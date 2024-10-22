// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ProfitDistributorWAPI is Ownable {
    using SafeMath for uint256;

    uint256 public profit; // Variable para almacenar las ganancias
    address public tokenAddress = 0x3328358128832A260C76A4141e19E2A943CD4B6D; // Dirección del token que debe tener el owner
    mapping(address => uint256) public balances; // Mapeo para los balances de los holders
    uint256 public totalSupply; // Suministro total de tokens

   // Constructor que recibe la dirección del propietario inicial
    constructor() Ownable() {
        // El propietario inicial será la dirección que despliega el contrato
        
    }

    // Función para recibir Ether y agregarlo a las ganancias
    receive() external payable {
        profit = profit.add(msg.value); // Acumula las ganancias en la variable profit
    }

    // Función para distribuir las ganancias
    function distributeProfits() public {
        require(totalSupply > 0, "No tokens in circulation");
        uint256 amountPerToken = profit.div(totalSupply); // Calculamos la cantidad de Ether que le toca por token

        address[] memory holders = getTokenHolders(); // Obtener la lista de holders
        for (uint256 i = 0; i < holders.length; i++) {
            address owner = holders[i];
            uint256 ownerBalance = balances[owner];
            uint256 ownerShare = amountPerToken.mul(ownerBalance); // Cantidad de Ether que le toca al owner
            (bool success, ) = owner.call{value: ownerShare}(""); // Transferencia segura
            require(success, "Transfer failed"); // Verificar la transferencia
        }
        profit = 0; // Reinicia las ganancias después de distribuir
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdraw failed");
    }

    function getTokenHolders() internal view returns (address[] memory) {
        uint256 holderCount = 0; // Inicializamos el contador
        for (uint256 i = 0; i < totalSupply; i++) { // Suponiendo que tienes un totalSupply que puedes recorrer
            if (balances[address(uint160(i))] > 0) { // Verificamos si hay al menos un token
                holderCount++; // Incrementamos el contador
            }
        }

        address[] memory holders = new address[](holderCount); // Creamos el array de holders
        uint256 index = 0; // Inicializamos el índice
        for (uint256 i = 0; i < totalSupply; i++) {
            if (balances[address(uint160(i))] > 0) {
                holders[index] = address(uint160(i)); // Asignamos la dirección al array
                index++;
            }
        }

        return holders; // Devolvemos el array de holders
    }

    // Función para que el propietario pueda actualizar el balance de los holders
    function updateBalance(address holder, uint256 amount) external onlyOwner {
        balances[holder] = amount; // Actualiza el balance del holder
        totalSupply = totalSupply.add(amount); // Actualiza el suministro total
    }
}
