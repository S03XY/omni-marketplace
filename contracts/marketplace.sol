// SPDX-License-Identifier:None
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace is IXReceiver, IERC721Receiver {
    address public owner;
    IERC721 public omnichainNFTContract;

    struct ListedNFT {
        bool isSold;
        bool isCanceled;
        uint256 amount;
        address seller;
        uint256 tokenId;
        address acceptedPaymentToken;
    }

    uint256 public currentIndex = 1;

    mapping(uint256 => ListedNFT) public ListedNFTInMarket;
    mapping(address => address) public tokenMapping;

    event ListNFTEvent(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 indexed amount,
        address acceptedPaymentToken
    );

    event BuyNFTEvent(address indexed buyer, uint256 indexed tokenId);
    event CloseListingEvent(address indexed seller, uint256 indexed tokenId);

    constructor(IERC721 omnichainNFTContract_) {
        omnichainNFTContract = omnichainNFTContract_;
        owner = msg.sender;

        tokenMapping[
            0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1
        ] = 0xeDb95D8037f769B72AAab41deeC92903A98C9E16;

        tokenMapping[
            0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
        ] = 0xFD2AB41e083c75085807c4A65C0A14FDD93d55A9;
    }

    function changeOwner(address newOwner_) external {
        require(msg.sender == owner, "Invalid Authority");
        owner = newOwner_;
    }

    function ChangeOmnichainNFTContract(IERC721 newOmnichainNFTContract)
        external
    {
        require(msg.sender == owner, "Invalid Authority");
        omnichainNFTContract = newOmnichainNFTContract;
    }

    function sellNFT(
        uint256 amount_,
        uint256 tokenId_,
        address acceptedPaymentToken_
    ) external {
        require(
            omnichainNFTContract.ownerOf(tokenId_) != address(this),
            "NFT already listed"
        );

        ListedNFTInMarket[currentIndex] = ListedNFT(
            false,
            false,
            amount_,
            msg.sender,
            tokenId_,
            acceptedPaymentToken_
        );

        omnichainNFTContract.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId_,
            ""
        );
        currentIndex += 1;

        emit ListNFTEvent(msg.sender, tokenId_, amount_, acceptedPaymentToken_);
    }

    function cancelListng(uint256 tokenId, uint256 tokenIndex) external {
        require(
            omnichainNFTContract.ownerOf(tokenId) == address(this),
            "Invalid tokenID"
        );

        ListedNFT storage listedNFTDetails = ListedNFTInMarket[tokenIndex];
        require(listedNFTDetails.isSold == false, "cannot close sold offfer");
        require(listedNFTDetails.seller == msg.sender, "Invalid Auth");
        listedNFTDetails.isCanceled = true;

        omnichainNFTContract.transferFrom(address(this), msg.sender, tokenId);

        emit CloseListingEvent(msg.sender, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes memory _callData
    ) external returns (bytes memory) {
        (
            address paymentToken,
            address buyer,
            uint256 tokenId,
            uint256 currentIndex
        ) = abi.decode(_callData, (address, address, uint256, uint256));

        require(
            omnichainNFTContract.ownerOf(tokenId) == address(this),
            "Invalid tokenId"
        );

        ListedNFT storage listedNFTDeatils = ListedNFTInMarket[currentIndex];

        // require(
        //     paymentToken == listedNFTDeatils.acceptedPaymentToken,
        //     "invalid payment"
        // );

        require(listedNFTDeatils.isSold == false, "already sold");
        require(listedNFTDeatils.isCanceled == false, "already cancelled");

        IERC20(tokenMapping[listedNFTDeatils.acceptedPaymentToken]).transfer(
            listedNFTDeatils.seller,
            _amount
        );

        omnichainNFTContract.transferFrom(address(this), buyer, tokenId);
        listedNFTDeatils.isSold = true;

        emit BuyNFTEvent(buyer, tokenId);
        return _callData;
    }
}
