// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "erc721a-upgradeable/contracts/extensions/ERC721AQueryableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract CustomERC721UpgradeableV1 is
    Initializable,
    OwnableUpgradeable,
    ERC721AQueryableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using StringsUpgradeable for uint256;
    using MerkleProofUpgradeable for bytes32;

    // State Variables jl
    string private baseTokenURI;
    string private hiddenTokenURI;
    bytes32 public rootHash;

    uint256 public price;
    uint256 public maxNfts;
    uint256 public maxNftsPerTx;
    uint256 public maxNftsPerAddressLimit;

    bool public paused;
    bool public revealed;
    bool public presale;

    mapping(address => uint256) public addressMintedBalance;

    // Initializing contract
    function initialize(
        string memory _baseTokenURL,
        string memory _hiddenTokenURL,
        bytes32 _rootHash
    ) public initializer {
        __ERC721A_init("Test NFT", "TNFT");
        __Ownable_init();
        __ReentrancyGuard_init();

        price = 0.012 ether;
        maxNfts = 10000;
        maxNftsPerTx = 3;
        maxNftsPerAddressLimit = 10;

        paused = false;
        revealed = false;
        presale = true;

        setBaseTokenURI(_baseTokenURL);
        setHiddenTokenURI(_hiddenTokenURL);
        setRootHash(_rootHash);
        __UUPSUpgradeable_init();
    }

    // Internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _mintNfts(address _receiver, uint256 _mintAmount) internal {
        _safeMint(_receiver, _mintAmount);
        addressMintedBalance[_msgSender()] =
            addressMintedBalance[_msgSender()] +
            _mintAmount;
    }

    // Modifiers
    modifier isPaused() {
        require(!paused, "Smart contract is paused currently !!");
        _;
    }

    modifier isPreSale() {
        require(presale, "Presale is live now !!");
        _;
    }

    modifier isPublicSale() {
        require(!presale, "Publicsale is live now !!");
        _;
    }

    modifier mintCompliance(uint256 _mintAmount, address _user) {
        require(
            _mintAmount > 0 && _mintAmount <= maxNftsPerTx,
            "Invalid mint amount !!"
        );
        require(
            totalSupply() + _mintAmount <= maxNfts,
            "NFTs are solded out !!"
        );

        require(
            addressMintedBalance[_user] + _mintAmount <= maxNftsPerAddressLimit,
            "You cannot mint more NFTS !!"
        );

        _;
    }

    // View Function
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenTokenURI;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ".json"
                    )
                )
                : "";
    }

    // Public Functions
    function mint(uint256 _mintAmount)
        public
        payable
        nonReentrant
        mintCompliance(_mintAmount, _msgSender())
        isPublicSale
        isPaused
    {
        require(
            msg.value >= price * _mintAmount,
            "Insufficient funds to mint !!"
        );
        _mintNfts(_msgSender(), _mintAmount);
    }

    function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
        nonReentrant
        mintCompliance(_mintAmount, _msgSender())
        isPreSale
    {
        require(
            MerkleProofUpgradeable.verify(
                _merkleProof,
                rootHash,
                keccak256(abi.encodePacked(_msgSender()))
            ),
            "You are not whitelisted !!"
        );
        require(
            PRICE * _mintAmount >= msg.value,
            "Insufficient funds to mint !!"
        );
        _mintNfts(_msgSender(), _mintAmount);
    }

    // Admin only
    function reveal() public onlyOwner {
        revealed = true;
    }

    function setNFTPerAddressLimit(uint256 _newLimit) public onlyOwner {
        NFT_LIMIT = _newLimit;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        PRICE = _newPrice;
    }

    function setMaxPerTx(uint256 _newLimit) public onlyOwner {
        MAX_PER_MINT = _newLimit;
    }

    function setBaseTokenURI(string memory _newBaseTokenURI) public onlyOwner {
        baseTokenURI = _newBaseTokenURI;
    }

    function setHiddenTokenURI(string memory _newHiddenTokenURI)
        public
        onlyOwner
    {
        hiddenTokenURI = _newHiddenTokenURI;
    }

    function setRootHash(bytes32 _newRootHash) public onlyOwner {
        rootHash = _newRootHash;
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

    function togglePresale() public onlyOwner {
        presale = !presale;
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
