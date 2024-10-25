import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import { ethers } from "hardhat";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/bcce9ad205234bdd8174fe5c64804a72", // Reemplaza con tu URL de Infura o Alchemy
      accounts: ["7OAEez2A2oafHKfuUuBGZoEsmd98tPFptbZeBJpg2lNwieG1yWpIvA"], // Reemplaza con tu clave privada
    },
  },
};

export default config;
