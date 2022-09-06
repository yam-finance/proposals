// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

interface ISablier {
    event CancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );
    event CreateStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    );
    event WithdrawFromStream(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    function balanceOf(uint256 streamId, address who)
        external
        view
        returns (uint256 balance);

    function cancelStream(uint256 streamId) external returns (bool);

    function createStream(
        address recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    ) external returns (uint256);

    function deltaOf(uint256 streamId) external view returns (uint256 delta);

    function getStream(uint256 streamId)
        external
        view
        returns (
            address sender,
            address recipient,
            uint256 deposit,
            address tokenAddress,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSecond
        );

    function nextStreamId() external view returns (uint256);

    function withdrawFromStream(uint256 streamId, uint256 amount)
        external
        returns (bool);
}
