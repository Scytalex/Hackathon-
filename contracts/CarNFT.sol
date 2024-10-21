// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.2/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.2/contracts/access/Ownable.sol";

contract CarNFT is ERC1155, Ownable {
    uint256 public constant CAR_TOKEN = 0; // ID del token que representa el carro
    uint256 public constant MAX_TOKENS = 10; // Número máximo de tokens que se pueden crear
    uint256 public tokenCount; // Contador de tokens creados

    // Constructor que inicializa el contrato ERC1155 con la URI base para los metadatos
    constructor() ERC1155("") {
        tokenCount = 0; // Inicializa el contador de tokens
    }

    // Función que permite al propietario del contrato crear un nuevo token
    function mintTokens() public onlyOwner {
        require(tokenCount < MAX_TOKENS, "Max tokens minted"); // Verifica que no se exceda el máximo
        tokenCount++; // Incrementa el contador de tokens
        _mint(msg.sender, CAR_TOKEN, 1, ""); // Crea 1 token para el carro y lo asigna al propietario
    }

    // Función que devuelve el número total de tokens creados
    function getTokenCount() public view returns (uint256) {
        return tokenCount; // Retorna el contador de tokens
    }
}
