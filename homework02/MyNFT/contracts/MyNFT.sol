// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    // Token ID计数器
    uint256 private _tokenIdCounter;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    event TokenURIUpdated(uint256 indexed tokenId, string newTokenURI);

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    /**
     * @dev 安全铸造NFT并设置元数据URI
     * @param to 接收者地址
     * @param uri 元数据URI（IPFS链接）
     */
    function safeMint(address to, string memory uri) public returns (uint256) {
        // 递增计数器
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, uri);
        
        emit NFTMinted(to, newTokenId, uri);
        return newTokenId;
    }

    /**
     * @dev 公开铸造函数（任何人都可以铸造）
     * @param uri 元数据URI
     */
    function mint(string memory uri) public returns (uint256) {
        return safeMint(msg.sender, uri);
    }

    /**
     * @dev 所有者批量铸造
     * @param to 接收者地址
     * @param uris 元数据URI数组
     */
    function batchMint(address to, string[] memory uris) public onlyOwner returns (uint256[] memory) {
        require(uris.length > 0, "No URIs provided");
        require(uris.length <= 10, "Too many URIs (max 10)");
        
        uint256[] memory tokenIds = new uint256[](uris.length);
        
        for (uint256 i = 0; i < uris.length; i++) {
            tokenIds[i] = safeMint(to, uris[i]);
        }
        
        return tokenIds;
    }

    /**
     * @dev 更新token的URI（仅所有者）
     * @param tokenId token ID
     * @param newUri 新的URI
     */
    function updateTokenURI(uint256 tokenId, string memory newUri) public onlyOwner {
        // 使用ownerOf来检查token是否存在，如果不存在会抛出错误
        ownerOf(tokenId); // 这会检查token是否存在
        require(bytes(newUri).length > 0, "URI cannot be empty");
        
        _setTokenURI(tokenId, newUri);
        emit TokenURIUpdated(tokenId, newUri);
    }

    /**
     * @dev 获取总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @dev 获取合约信息
     */
    function getContractInfo() public view returns (string memory, string memory, uint256) {
        return (name(), symbol(), totalSupply());
    }

    /**
     * @dev 获取指定token的信息
     * @param tokenId token ID
     */
    function getTokenInfo(uint256 tokenId) public view returns (address owner, string memory uri) {
        // 使用ownerOf来检查token是否存在
        owner = ownerOf(tokenId); // 这会检查token是否存在
        uri = tokenURI(tokenId);
    }

    /**
     * @dev 检查token是否存在
     * @param tokenId token ID
     */
    function tokenExists(uint256 tokenId) public view returns (bool) {
        try this.ownerOf(tokenId) {
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev 获取当前可用的下一个token ID
     */
    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter + 1;
    }

    /**
     * @dev 获取所有者的token列表
     * @param owner 所有者地址
     */
    function getTokensByOwner(address owner) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);
        
        uint256 index = 0;
        for (uint256 tokenId = 1; tokenId <= _tokenIdCounter; tokenId++) {
            if (tokenExists(tokenId) && ownerOf(tokenId) == owner) {
                tokens[index] = tokenId;
                index++;
                if (index == balance) break;
            }
        }
        
        return tokens;
    }

    // 重写必要的函数以支持ERC721URIStorage
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721)
    {
        super._increaseBalance(account, value);
    }
}