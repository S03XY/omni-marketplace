// SPDX-License-Identifier:None

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnmichainNFT is ERC721 {
    address public omnichainOwner;
    uint256 public tokenMinted;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        omnichainOwner = msg.sender;
    }

    function changeOmnichainOwner(address newOmnichainOnwer) external {
        require(msg.sender == omnichainOwner, "Invalid Authority");
        omnichainOwner = newOmnichainOnwer;
    }

    function mintToken() external {
        _mint(msg.sender, tokenMinted);
        tokenMinted += 1;
    }

    function burnToken(uint256 tokenId) external {
        _burn(tokenId);
    }
}
