// SPDX-Licenser-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DogeNFT is ERC721 {
    error DogeNFT__TokenUriNotFound();

    mapping(uint256 tokenId => string tokenUri) private s_tokenURIs;
    uint256 private s_tokenCounter;

    constructor() ERC721("DOGIE", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNFT(string memory tokenUri) public {
        s_tokenURIs[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert DogeNFT__TokenUriNotFound();
        }
        return s_tokenURIs[tokenId];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
