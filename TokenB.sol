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
 * @title TokenB
 * @dev ERC20 Token with minting capability by owner.
 */
contract TokenB is ERC20, Ownable {
    constructor()
        ERC20("TokenB", "TKB")
        Ownable(0x65597147f73A9eB8616c0AD69724E427F6d895b1)
    {}
//to add some "Bizcochitos"
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}