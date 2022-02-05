// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Erc20TokenWithFaucet is ERC20 {
    mapping(address => uint256) private _balances;

    constructor(string memory tokenName, string memory tokenSymbol)
        ERC20(tokenName, tokenSymbol)
    {}

    function faucet() public {
        require(_msgSender() != address(0), "Cant be the 0 address");

        uint256 amount = 100000000000000000000;
        _mint(_msgSender(), amount);
        _balances[_msgSender()] += amount;
    }
}
