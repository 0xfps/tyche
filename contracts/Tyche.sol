// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ITyche} from "./interfaces/ITyche.sol";

import {Guard} from "./utils/Guard.sol";

import {TycheToken} from "./utils/TycheToken.sol";

/**
* @title Tyche.
* @author Anthony (fps) https://github.com/0xfps.
* @dev NFT Rating Protocol.
*/
abstract contract Tyche is ITyche, Guard {
    /// @dev NFT Data.
    struct NFTData {
        bool _isValid;
        string _type;
        address _lister;
        uint256 _id;
        string _uri;
        uint256 _totalVotes;
        uint256 _totalPossibleVotes;
    }

    /// @dev Admin contract.
    address private admin;
    /// @dev TycheToken
    address private immutable tycheToken;

    /// @dev Total NFTs listed on the protocol.
    uint256 private totalNFTsListed;
    /// @dev Total NFTs withdrawn on the protocol.
    uint256 private totalNFTsWithdrawn;
    /// @dev Listings.
    mapping(address => NFTData) private listings;
    /// @dev Blacklist.
    mapping(address => bool) private blacklist;

    /// @dev Ensures that the address is NOT in the blacklist.
    modifier notInBlacklist(address _address) {
        require(!blacklist[_address], "In blacklist.");
        _;
    }

    constructor(address _address) {
        require(_address != address(0), "0x0 Address.");
        admin = _address;

        /// @dev    Deploy TycheToken and set this contract as main 
        ///         receiver of all tokens.
        tycheToken = address(new TycheToken(address(this)));
    }

    /// @dev Send money back to whoever sends it.
    receive() external payable {
        (bool sent, ) = payable(msg.sender).call{value: msg.value}("");
        sent;   // Unused.
    }

    /**
    * @inheritdoc ITyche
    */
    function listERC721NFT(
        address _address, 
        uint256 _id, 
        string memory _uri
    ) 
    public 
    override 
    notInBlacklist(_address)
    returns(bool) {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the caller is the owner of the NFT.
        require(IERC721(_address).ownerOf(_id) == msg.sender, "!Owner");
        /// @dev Ensure the `_uri` is not empty.
        require(bytes(_uri).length != 0, "!URI");

        /// @dev Generate NFT data to memory.
        NFTData memory _NFTData = NFTData(
            true,
            "721",
            msg.sender,
            _id, _uri, 0, 0
        );

        /// @dev Store generated NFT data to map.
        listings[_address] = _NFTData;

        /// @dev Emit {List721} Event.
        emit List721(msg.sender, _address);

        /// @dev Return true.
        return true;
    }

    /**
    * @inheritdoc ITyche
    */
    function listERC1155NFT(
        address _address, 
        uint256 _id, 
        string memory _uri
    ) 
    public 
    override 
    notInBlacklist(_address)
    returns(bool) {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the caller is the owner of the NFT.
        require(IERC1155(_address).balanceOf(msg.sender, _id) > 0, "!Owner");
        /// @dev Ensure the `_uri` is not empty.
        require(bytes(_uri).length != 0, "!URI");

        /// @dev Generate NFT data to memory.
        NFTData memory _NFTData = NFTData(
            true,
            "1155",
            msg.sender,
            _id, _uri, 0, 0
        );

        /// @dev Store generated NFT data to map.
        listings[_address] = _NFTData;

        /// @dev Emit {List721} Event.
        emit List1155(msg.sender, _address);

        /// @dev Return true.
        return true;
    }

    /// @dev Validates address.
    /// @param _address Address to be validated.
    function _validateAddress(address _address) private view {
        require(_address != address(0), "0x0 Address");
        require(_address != admin, "Admin");
        _address; // Unused.
    }
    
    /// @dev Adds to blacklist from admin.
    /// @param _address Address to be added to blacklist.
    function addToBlacklist(address _address) public {
        require(msg.sender == admin, "!Admin");
        blacklist[_address] = true;
    }
}