// 
// ██╗     ███████╗ ██████╗  ██████╗ ███████╗
// ██║     ██╔════╝██╔═══██╗██╔════╝ ╚══███╔╝
// ██║     █████╗  ██║   ██║██║  ███╗  ███╔╝ 
// ██║     ██╔══╝  ██║   ██║██║   ██║ ███╔╝  
// ███████╗███████╗╚██████╔╝╚██████╔╝███████╗
// ╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenMate
 * @dev ERC20 Token with minting capability by owner.
 */
contract TokenMate is ERC20, Ownable {
    constructor()
        ERC20("TokenMate", "MATE")
        Ownable(0xcc103f69B3Ae608eD5265dEFe0ac046ae2e21B6D)
    {}
//to add some "Matecitos"
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}