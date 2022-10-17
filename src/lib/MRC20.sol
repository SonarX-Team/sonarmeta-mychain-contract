pragma solidity ^0.8.14;

import "../utils/Ownable.sol";

contract MRC20 is Ownable {

    event Transfer(identity indexed from, identity indexed to, uint256 amount);
    event Approval(identity indexed owner, identity indexed spender, uint256 amount);

    mapping(identity => uint256) private _balances;
    mapping(identity => mapping(identity => uint256)) private _allowances;
    uint256 private _totalSupply;

    function airdrop(identity _applicant, uint256 _amount) onlyOwner external {
        _mint(_applicant, _amount);
    }

    /**
     * @dev See {IMRC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IMRC20-balanceOf}.
     */
    function balanceOf(identity account) public view returns (uint256) {
        return _balances[account];
    }

        /**
     * @dev See {IMRC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero identity.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(identity to, uint256 amount) public  returns (bool) {
        identity owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IMRC20-allowance}.
     */
    function allowance(identity owner, identity spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IMRC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero identity.
     */
    function approve(identity spender, uint256 amount) public  returns (bool) {
        identity owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IMRC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {MRC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero identity.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        identity from,
        identity to,
        uint256 amount
    ) public  returns (bool) {
        identity spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

        /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero identity.
     * - `to` cannot be the zero identity.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        identity from,
        identity to,
        uint256 amount
    ) internal virtual {
        require(from != identity(0), "MRC20: transfer from the zero identity");
        require(to != identity(0), "MRC20: transfer to the zero identity");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "MRC20: transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero identity.
     *
     * Requirements:
     *
     * - `account` cannot be the zero identity.
     */
    function _mint(identity account, uint256 amount) internal virtual {
        require(account != identity(0), "MRC20: mint to the zero identity");

        _totalSupply += amount;
        // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        _balances[account] += amount;
        emit Transfer(identity(0), account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero identity.
     * - `spender` cannot be the zero identity.
     */
    function _approve(
        identity owner,
        identity spender,
        uint256 amount
    ) internal virtual {
        require(owner != identity(0), "MRC20: approve from the zero identity");
        require(spender != identity(0), "MRC20: approve to the zero identity");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        identity owner,
        identity spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        // unsafe
        require(currentAllowance >= amount, "MRC20: insufficient allowance");
        _approve(owner, spender, currentAllowance - amount);
    }

}
