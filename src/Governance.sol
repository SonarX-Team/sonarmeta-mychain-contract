pragma solidity ^0.8.14;

/// @title SonarMeta Governance contract
/// @author SonarX Team
contract Governance {

    /// @notice identity which governs SonarMeta
    identity public networkGovernor;

    /// @notice identity which belongs to SonarMeta, taking control of tokens
    mapping(identity => bool) public networkControllers;

    /// @notice identity which controls treasures for contract
    identity public treasury;

    constructor() public {
        networkGovernor = msg.sender;
    }

    /// @notice Check if specified identity is is governor
    /// @param _identity identity to check
    function requireGovernor(identity _identity) public view {
        require(_identity == networkGovernor, "ng"); // only by governor
    }

    /// @notice Check if specified identity is is controller
    /// @param _identity identity to check
    function requireController(identity _identity) public view {
        require(networkControllers[_identity], "nc"); // only by controller
    }

    /// @notice Change current governor
    /// @param _newGovernor identity of the new governor
    function changeGovernor(identity _newGovernor) external {
        requireGovernor(msg.sender);
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
        }
    }

    /// @notice Change controller status (active or not active)
    /// @param _controller Controller identity
    /// @param _active Active flag
    function setController(identity _controller, bool _active) external {
        requireGovernor(msg.sender);
        if (networkControllers[_controller] != _active) {
            networkControllers[_controller] = _active;
        }
    }

    /// @notice Change identity that controls treasured
    /// @notice Can be called only by governor
    /// @param _newTreasury new treasury identity
    function setTreasury(identity _newTreasury) external {
        requireGovernor(msg.sender);
        treasury = _newTreasury;
    }
}
