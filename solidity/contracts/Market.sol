// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Market {
    IERC20 private _tokenA;
    IERC20 private _tokenB;

    uint256 private _tokenASupply = 0;
    uint256 private _tokenBSupply = 0;

    mapping(address => mapping(address => uint256)) private _reserves;
    mapping(address => mapping(address => uint256)) private _balances;

    constructor(address tokenA, address tokenB) {
        _tokenA = IERC20(tokenA);
        _tokenB = IERC20(tokenB);
    }

    /* -------- MUTATING FUNCTIONS -------- */
    function provideLiquidity(uint256 amountA, uint256 amountB) public {
        require(
            _tokenA.balanceOf(msg.sender) >= amountA,
            "Sender doesnt have enough ERCB0 Token A amount"
        );
        require(
            _tokenB.balanceOf(msg.sender) >= amountB,
            "Sender doesnt have enough ERCB0 Token B amount"
        );

        _tokenA.transferFrom(msg.sender, address(this), amountA);
        _tokenB.transferFrom(msg.sender, address(this), amountB);

        _balances[msg.sender][address(_tokenA)] += amountA;
        _balances[msg.sender][address(_tokenB)] += amountB;

        _reserves[address(this)][address(_tokenA)] += amountA;
        _reserves[address(this)][address(_tokenB)] += amountB;
    }

    function swapAForB(uint256 amountA, uint256 amountB) public {
        require(
            _tokenA.balanceOf(msg.sender) >= amountA,
            "Sender doesnt have enough ERCB0 token A amount"
        );
        require(
            _tokenB.balanceOf(msg.sender) >= amountB,
            "Sender doesnt have enough ERCB0 token B amount"
        );
        require(
            _reserves[address(this)][address(_tokenA)] >= amountA,
            "Not enough token A in the pool"
        );
        require(
            _reserves[address(this)][address(_tokenB)] >= amountB,
            "Not enough token B in the pool"
        );

        _tokenA.transferFrom(msg.sender, address(this), amountA);
        _tokenB.transfer(msg.sender, amountB);

        _balances[msg.sender][address(_tokenA)] += amountA;
        _balances[msg.sender][address(_tokenB)] -= amountB;

        _reserves[address(this)][address(_tokenA)] += amountA;
        _reserves[address(this)][address(_tokenB)] -= amountB;
    }

    /* -------- PURE FUNCTIONS -------- */

    function totalReserve() public view returns (uint256[2] memory) {
        return [reserveOf(address(_tokenA)), reserveOf(address(_tokenB))];
    }

    function balanceOf(address account)
        public
        view
        returns (uint256[2] memory)
    {
        uint256[2] memory balance;

        balance = [
            _balances[account][address(_tokenA)],
            _balances[account][address(_tokenB)]
        ];

        return balance;
    }

    function reserveOf(address token) public view returns (uint256) {
        return _reserves[address(this)][address(token)];
    }
}
