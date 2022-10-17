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
contract Tyche is ITyche, Guard {
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
    function listNFT(
        address _address, 
        uint256 _id, 
        string memory _uri
    ) public override notInBlacklist(_address) returns(bool) 
    {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the caller is the owner of the NFT.
        require(isOwner(_address, _id), "!Owner");
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

        /// @dev Send token rewards for listing.
        sendRewards(msg.sender, 10);

        /// @dev Emit {List721} Event.
        emit List(msg.sender, _address);

        return true;
    }

    /**
    * @inheritdoc ITyche
    */
    function withdrawNFT(address _address, uint256 _id) 
    public 
    override 
    returns(bool) 
    {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the NFT is valid.
        require(listings[_address]._isValid, "Withdrawn.");
        /// @dev Ensure the caller is the owner of the NFT.
        require(isOwner(_address, _id), "!Owner");

        /// @dev Remove NFT.
        delete listings[_address];

        /// @dev Emit {Withdraw} event.
        emit Withdraw(msg.sender, _address);

        return true;
    }

    /**
    * @inheritdoc ITyche
    */
    function rateNFT(address _address, uint8 _rate) 
    public
    override
    noReentrance
    returns(bool)
    {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the NFT is valid.
        require(listings[_address]._isValid, "Withdrawn.");

        /// @dev Add to voted rate (+rate) and total possible vote (+10).
        listings[_address]._totalVotes += uint256(_rate);
        listings[_address]._totalPossibleVotes += 10;

        /// @dev Send token rewards for rating.
        sendRewards(msg.sender, 5);

        emit Rate(msg.sender, _address, _rate);
        // emit Reward(msg.sender);

        return true;
    }

    /**
    * @inheritdoc ITyche
    */
    function getNFTRatingPercentage(address _address) 
    public 
    view 
    override
    returns(uint256 _value)
    {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the NFT is valid.
        require(listings[_address]._isValid, "Withdrawn.");

        /// @dev    Get total votes for the NFT and total possible votes
        ///         and calculate the percentage of the former to the latter.
        uint256 total = listings[_address]._totalVotes;
        uint256 possible = listings[_address]._totalPossibleVotes;

        /// @dev Return percentage.
        _value = (total * 100) / possible;
    }

    /**
    * @inheritdoc ITyche
    */
    function getNFTURI(address _address) 
    public 
    view 
    override
    returns(string memory _uri) 
    {
        /// @dev Validate address.
        _validateAddress(_address);
        /// @dev Ensure the NFT is valid.
        require(listings[_address]._isValid, "Withdrawn.");

        _uri = listings[_address]._uri;
    }

    /// @dev Validates address.
    /// @param _address Address to be validated.
    function _validateAddress(address _address) private view {
        require(_address != address(0), "0x0 Address");
        require(_address != admin, "Admin");
        _address; // Unused.
    }

    /// @dev Validates that caller owns the NFT listed.
    /// @param _address NFT address.
    /// @param _id      Token Id.
    function isOwner(address _address, uint256 _id) private view returns(bool) {
        /// @dev    True or false if that the NFT is owned by the caller for 721 OR 
        ///         caller owns at least, one token batch if it is a 1155 NFT.
        bool owned = (IERC721(_address).ownerOf(_id) == msg.sender) ||
                        (IERC1155(_address).balanceOf(msg.sender, _id) > 0);
        return owned;
    }
    
    /// @dev Adds to blacklist from admin.
    /// @param _address Address to be added to blacklist.
    function addToBlacklist(address _address) public {
        require(msg.sender == admin, "!Admin");
        blacklist[_address] = true;

        /// @dev Remove NFT.
        delete listings[_address];
    }

    /// @dev Remove from blacklist from admin.
    /// @param _address Address to be removed from blacklist.
    function removeFromBlacklist(address _address) public {
        require(msg.sender == admin, "!Admin");
        blacklist[_address] = false;
    }

    /// @dev Sends `_amount` amount of $TYCHE tokens to `_to`.
    /// @param _to      Recipient address.
    /// @param _amount   Amount to send.
    function sendRewards(address _to, uint256 _amount) private {
        TycheToken(tycheToken).transfer(_to, (_amount * 10e9));

        emit Reward(_to, _amount);
    }
}