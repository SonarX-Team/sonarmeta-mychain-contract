// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./Governance.sol";
import "./lib/MRC20.sol";
import "./lib/MRC721.sol";
import "./lib/MRC998.sol";
import "./utils/Ownable.sol";

/// @title SonarMeta main contract
/// @author SonarX Team
contract SonarMeta is Ownable {

    event Fund(identity indexed _to, uint256 _amount);
    event MintModelFor(identity indexed _to, uint256 indexed _tokenId);
    event MintSceneFor(identity indexed _to, uint256 indexed _tokenId);

    uint256 internal constant AIRDROP_AMOUNT = 1000000000000000000000;

    mapping(identity => bool) public appliedAirdropWhitelist;

    MRC20 internal MRC20Token;
    MRC721 internal MRC721ModelCollection;
    MRC998 internal MRC998SceneCollection;
    Governance internal governance;

    constructor(identity _tokenIdentity, identity _modelCollectionIdentity, identity _sceneCollectionIdentity, identity _governanceIdentity) public {
        governance = Governance(_governanceIdentity);
        MRC20Token = MRC20(_tokenIdentity);
        MRC721ModelCollection = MRC721(_modelCollectionIdentity);
        MRC998SceneCollection = MRC998(_sceneCollectionIdentity);
    }
    function applyForAirdrop() external {
        require(appliedAirdropWhitelist[msg.sender] == false, "haa");
        MRC20Token.airdrop(msg.sender, AIRDROP_AMOUNT);
        appliedAirdropWhitelist[msg.sender] = true;
        emit Fund(msg.sender, AIRDROP_AMOUNT);
    }

    function fundTreasury(uint256 _amount) external {
        governance.requireController(msg.sender);
        require(governance.treasury() != identity(0), "tsi0");
        MRC20Token.airdrop(governance.treasury(), _amount);
        emit Fund(governance.treasury(), _amount);
    }

    function transferMRC20UsingSonarMetaAllowance(identity _from, identity _to, uint256 _amount) external {
        governance.requireController(msg.sender);
        require(_amount != 0, "ai0");
        require(_from != identity(0), "fi0");
        require(_to != identity(0), "ti0");
        require(MRC20Token.transferFrom(_from, _to, _amount), "tf");
    }

    function grantMRC721UsingSonarMetaApproval(uint256 _tokenId, identity _to) external {
        governance.requireController(msg.sender);
        require(_to != identity(0), "ti0");
        identity owner = MRC721ModelCollection.ownerOf(_tokenId);
        /// @dev owner cannot be '0' because it is checked inside 'ownerOf'.
        MRC721ModelCollection.grantFrom(owner, _to, _tokenId);
    }

    function transferMRC721UsingSonarMetaApproval(uint256 _tokenId, identity _to) external {
        governance.requireController(msg.sender);
        require(_to != identity(0), "ti0");
        identity owner = MRC721ModelCollection.ownerOf(_tokenId);
        /// @dev owner cannot be '0' because it is checked inside 'ownerOf'.
        MRC721ModelCollection.transferFrom(owner, _to, _tokenId);
    }

    function mintMRC721(identity _to) external returns(uint256 _tokenId){
        governance.requireController(msg.sender);
        require(_to!= identity(0), "ti0");
        _tokenId = MRC721ModelCollection.mint(_to);

        emit MintModelFor(_to, _tokenId);
    }

    function grantMRC998UsingSonarMetaApproval(uint256 _tokenId, identity _to) external {
        governance.requireController(msg.sender);
        require(_to != identity(0), "ti0");
        identity owner = MRC998SceneCollection.ownerOf(_tokenId);
        /// @dev owner cannot be '0' because it is checked inside 'ownerOf'.
        MRC998SceneCollection.grantFrom(owner, _to, _tokenId);
    }

    function transferMRC998UsingSonarMetaApproval(uint256 _tokenId, identity _to) external {
        governance.requireController(msg.sender);
        require(_to != identity(0), "ti0");
        identity owner = MRC998SceneCollection.ownerOf(_tokenId);
        /// @dev owner cannot be '0' because it is checked inside 'ownerOf'.
        MRC998SceneCollection.transferFrom(owner, _to, _tokenId);
    }

    function mintMRC998(identity _to) external returns(uint256 _tokenId){
        governance.requireController(msg.sender);
        require(_to!= identity(0), "ti0");
        _tokenId = MRC998SceneCollection.mint(_to);

        emit MintSceneFor(_to, _tokenId);
    }

    function mintMRC998WithBatchTokens(identity _to, uint256[] calldata _childTokenIds) external returns(uint256 _tokenId) {
        governance.requireController(msg.sender);
        require(_to!= identity(0), "ti0");
        _tokenId = MRC998SceneCollection.mintFromBatchTokens(_to, _childTokenIds);

        emit MintSceneFor(_to, _tokenId);
    }

}
