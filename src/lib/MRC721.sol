pragma solidity ^0.8.14;

import "../utils/Counters.sol";
import "../utils/Ownable.sol";

contract MRC721 is Ownable {

    using Counters for Counters.Counter;
    // Auto increment counter
    Counters.Counter private _index;

    event Transfer(identity indexed from, identity indexed to, uint256 indexed tokenId);
    event Approval(identity indexed owner, identity indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(identity indexed owner, identity indexed operator, bool approved);

    mapping(uint256 => identity) private _owners;
    mapping(identity => uint256) private _balances;
    mapping(uint256 => identity) private _tokenApprovals;
    mapping(identity => mapping(identity => bool)) private _operatorApprovals;
    mapping(uint256 => mapping(identity => bool)) private grantedToken;
    mapping(uint256 => mapping(identity => bool)) private approvedGranting;

    /**
     * @dev See {IMRC721-balanceOf}.
     */
    function balanceOf(identity owner) public view returns (uint256) {
        require(owner != identity(0), "MRC721: identity zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IMRC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view returns (identity) {
        identity owner = _ownerOf(tokenId);
        require(owner != identity(0), "MRC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IMRC721-approve}.
     */
    function approve(identity to, uint256 tokenId) public {
        identity owner = MRC721.ownerOf(tokenId);
        require(to != owner, "MRC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "MRC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IMRC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view returns (identity) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IMRC721-setApprovalForAll}.
     */
    function setApprovalForAll(identity operator, bool approved) public {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IMRC721-isApprovedForAll}.
     */
    function isApprovedForAll(identity owner, identity operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IMRC721-transferFrom}.
     */
    function transferFrom(
        identity from,
        identity to,
        uint256 tokenId
    ) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "MRC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IMRC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        identity from,
        identity to,
        uint256 tokenId
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "MRC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the MRC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero identity.
     * - `to` cannot be the zero identity.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IMRC721Receiver-onMRC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        identity from,
        identity to,
        uint256 tokenId
    ) internal {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view returns (identity) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != identity(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(identity spender, uint256 tokenId) internal view returns (bool) {
        identity owner = MRC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }


    /**
     * @dev Same as {xref-MRC721-_safeMint-identity-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IMRC721Receiver-onMRC721Received} to contract recipients.
     */
    function _safeMint(
        identity to,
        uint256 tokenId
    ) internal {
        _mint(to, tokenId);
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero identity.
     *
     * Emits a {Transfer} event.
     */
    function _mint(identity to, uint256 tokenId) internal {
        require(to != identity(0), "MRC721: mint to the zero identity");
        require(!_exists(tokenId), "MRC721: token already minted");

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "MRC721: token already minted");

        // Will not overflow unless all 2**256 token ids are minted to the same owner.
        // Given that tokens are minted one by one, it is impossible in practice that
        // this ever happens. Might change if we allow batch minting.
        // The ERC fails to describe this case.
        _balances[to] += 1;
        
        _owners[tokenId] = to;

        emit Transfer(identity(0), to, tokenId);

    }

        /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero identity.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        identity from,
        identity to,
        uint256 tokenId
    ) internal {
        require(MRC721.ownerOf(tokenId) == from, "MRC721: transfer from incorrect owner");
        require(to != identity(0), "MRC721: transfer to the zero identity");

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(MRC721.ownerOf(tokenId) == from, "MRC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
        // `from`'s balance is the number of token held, which is at least one before the current
        // transfer.
        // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
        // all 2**256 token ids to be minted, which in practice is impossible.
        _balances[from] -= 1;
        _balances[to] += 1;
        
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(identity to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(MRC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        identity owner,
        identity operator,
        bool approved
    ) internal {
        require(owner != operator, "MRC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "MRC721: invalid token ID");
    }

    function approveGrant(identity to, uint256 tokenId) public {
        identity owner = ownerOf(tokenId);
        require(to != owner, "gtco");
        /// grant to current owner
        require(
            msg.sender == owner,
            "np"
        );
        _approveGrant(to, tokenId);
    }

    function _approveGrant(identity to, uint256 tokenId) internal {
        approvedGranting[tokenId][to] = true;
    }

    function grantFrom(identity from, identity to, uint256 tokenId) public {
        require(_isApprovedGrantingidentityOrOwner(msg.sender, tokenId), "np");
        _grant(from, to, tokenId);
    }

    /// @dev Spender may be the owner or the approved granting identity
    function _isApprovedGrantingidentityOrOwner(identity spender, uint256 tokenId) internal view returns (bool) {
        identity owner = ownerOf(tokenId);
        return (spender == owner || isApprovedGranting(tokenId, spender));
    }

    function isApprovedGranting(uint256 tokenId, identity addr) public view returns (bool) {
        _requireMinted(tokenId);
        return approvedGranting[tokenId][addr];
    }

    function isGranted(identity _identity, uint256 tokenId) public view returns (bool) {
        _requireMinted(tokenId);
        return grantedToken[tokenId][_identity];
    }


    function _grant(identity from, identity to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "fno");
        require(to != identity(0), "ti0");
        grantedToken[tokenId][to] = true;
    }

    function mint(identity to) public onlyOwner returns(uint256) {
        require(to != identity(0), "ti0");
        uint256 index = _index.current();
        _safeMint(to, index);
        _index.increment();
        return index;
    }
}
