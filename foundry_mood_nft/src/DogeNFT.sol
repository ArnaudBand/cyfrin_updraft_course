// SPDX-Licenser-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DogeNFT is ERC721 {
    uint256 private s_tokenCounter;

    mapping(uint256 => string) private s_tokenURIs;

    constructor() ERC721("DOGIE", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNFT(string memory tokenURI) public {
        s_tokenURIs[s_tokenCounter] = tokenURI;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenURIs[tokenId];
    }
}
