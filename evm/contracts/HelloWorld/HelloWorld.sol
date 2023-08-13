// contracts/VotingDapp.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/ICallService.sol";

/**
 * @title HelloWorld
 * @dev Implements the hellow world contract
 */
contract HelloWorld {
  address private xcallContractAddress;
  string private destinationBtpAddress;

  /**
     @notice Initialize
     @param _xcallContractAddress The address of the contract that will only be allowed to call the handleCallMessage function
     @param _destinationBtpAddress The BTP address of the destination chain
   */
  function initialize(
    address _xcallContractAddress,
    string calldata _destinationBtpAddress) external payable {
    xcallContractAddress = _xcallContractAddress;
    destinationBtpAddress = _destinationBtpAddress;
  }

  /**
  */
 function sendMessage(
   bytes calldata _data,
   bytes calldata _rollback
 ) external payable returns (uint256) {
   uint256 id = ICallService(xcallContractAddress).sendCallMessage(destinationBtpAddress, _data, _rollback);
   return id;
 }

  /**
     @notice Compares two strings
     @param _base The first string
     @param _value The second string
     @return True if the strings are equal, false otherwise
   */
  function compareTo(
      string memory _base,
      string memory _value
  ) internal pure returns (bool) {
      if (
          keccak256(abi.encodePacked(_base)) ==
          keccak256(abi.encodePacked(_value))
      ) {
          return true;
      }
      return false;
  }

  /**
     @notice Handles the call message received from the source chain.
     @dev Only calleable from the xcallContractAddress which is the xCall contract.
     @param _from The BTP address of the caller on the source chain
     @param _data The calldata delivered from the caller
   */
  function handleCallMessage(
      string calldata _from,
      bytes calldata _data
  ) external payable {
    // Only the xCall contract can call this function
    if (msg.sender != xcallContractAddress) {
      revert("InvalidSender");
    }

    // Only the HelloWorld contract on the source chain can call this function
    if (!compareTo(destinationBtpAddress, _from)) {
      revert("InvalidFrom");
    }

    // Convert the calldata to a string
    string memory msgData = string(_data);

    // Emit the message received event
    emit MessageReceived(_from, msgData);

    // If the message is "executeRollback" raise event to notify
    // that a rollback was executed
    if (compareTo("executeRollback", msgData)) {
      // Emit the rollback event
      emit RollbackDataReceived(_from, msgData);
      revert("ExecuteRollback");
    }
  }

  /**
     @notice Handles the reply message received from the source chain.
     @dev Only called from the Call Message Service.
     @param _from The BTP address of the caller on the source chain
     @param _msgData The cross chain data sent
   */
  event MessageReceived(
      string _from,
      string _msgData
  );

  /**
     @notice Handles the rollback message received from the source chain.
     @dev Only called from the Call Message Service.
     @param _from The BTP address of the caller on the source chain
     @param _msgData The cross chain data sent
   */
  event RollbackDataReceived(
      string _from,
      string _msgData
  );
}
