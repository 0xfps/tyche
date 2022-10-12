// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

/**
* @title ITyche.
* @author Anthony (fps) https://github.com/0xfps.
* @dev Interface for the Tyche contract.
*/
interface ITyche {
    /// @dev Emitted when an ERC721 NFT is listed.
    event List(address _owner, address _nft);
    /// @dev Emitted when an NFT is withdrawn.
    event Withdraw(address _owner, address _nft);
    /// @dev Emitted when an NFT is rated.
    event Rate(address _rater, address _nft, uint8 _rate);
    /// @dev Emitted when some $TYCHE tokens is sent to an address.
    event Reward(address _receiver, uint256 _reward);

    /**
    * @dev  Allows the caller to list an NFT on the protocol. It is
    *       worthy to note that only NFT owners can list their tokens, and 
    *       tokens can be listed if they are not on the blacklist.
    *       This will emit the {List} event.
    *
    * @param _address   Contract address of the NFT.
    * @param _id        Token Id.
    * @param _uri       String URI of the particular token Id.
    *
    * @return bool.
    */
    function listNFT(
        address _address, 
        uint256 _id, 
        string memory _uri
    ) external returns(bool);

    /**
    * @dev  Allows the caller to bring down an NFT already listed. This
    *       caller must be the address that owns this NFT. Should an address
    *       list this NFT, and sell it, the new owner is the address valid
    *       to withdraw it.
    *       This will emit the {Withdraw} event.
    *
    * @param _address   Contract address of the NFT.
    * @param _id        Token Id.
    *
    * @return bool.
    */    
    function withdrawNFT(address _address, uint256 _id) external returns(bool);

    /**
    * @dev  This function allows a caller to rate a particular NFT by voting
    *       on it on on a scale from 1 - 10 (lowest to highest). This rewards 
    *       the rater or voter with some amount of $TYCHE tokens.
    *       This emits the {Rate} and {Reward} event.
    *
    * @param _address   Contract address of the NFT.
    * @param _rate      Rate score between 1 - 10.
    *
    * @return bool.
    */
    function rateNFT(address _address, uint8 _rate) external returns(bool);

    /**
    * @dev  Return the percentage rating of a particular NFT.
    *
    * @param _address   Contract address of the NFT.
    *
    * @return _value Rate value.
    */
    function getNFTRatingPercentage(address _address) 
    external 
    view 
    returns(uint256 _value);

    /**
    * @dev Returns the URI string of the NFT.
    *
    * @param _address   Contract address of the NFT.
    *
    * @return _uri String URI.
    */
    function getNFTURI(address _address) external view returns(string memory _uri);
}