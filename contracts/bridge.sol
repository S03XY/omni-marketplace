// SPDX-License-Identifier:None
pragma solidity 0.8.17;

import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bridge {
    IConnext public immutable connext;

    constructor(IConnext _connext) {
        connext = _connext;
    }

    function bridgedTransfer(
        address recipient,
        uint32 destinationDomain,
        address tokenAddress,
        uint256 amount,
        uint256 slippage,
        uint256 relayerFee,
        uint256 tokenId,
        uint256 currentIndex
    ) external payable {
        IERC20 token = IERC20(tokenAddress);
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "User must approve amount"
        );

        token.transferFrom(msg.sender, address(this), amount);

        bytes memory data = abi.encode(
            tokenAddress,
            msg.sender,
            tokenId,
            currentIndex
        );

        token.approve(address(connext), amount);
        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            recipient, // _to: address receiving the funds on the destination
            tokenAddress, // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            amount, // _amount: amount of tokens to transfer
            slippage, // _slippage: the maximum amount of slippage the user will accept in BPS
            data // _callData: empty because we're only sending funds
        );
    }
}
