// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ArtemisBallot {

  struct Voter {
    uint weight;        //  weight is normally accumulated by delegation
    bool voted;         //  true when person already voted
    address delegate;   //  the nation delegated to
    uint vote;          //  the vote proposal's index
  }

  struct Proposal {
    bytes32 name;       //  proposal name (32 bytes long)
    uint voteCount;     //  number of accumulated votes
  }

  /// @notice Mapping of all voters' addresses
  mapping(address => Voter) public voters;

  address public chairperson;

  /// @notice Dynamic array of proposals
  Proposal[] public proposals;

  /// @notice On Contract Initialisation: We create a new ballot
  constructor(bytes32[] memory proposalNames) public {
    // 1. Ensure the deployer is the chairperson
    // 2. Chairperson must have a weight of 1
    // 3. 

  }

  /// @notice Modifier to ensure only chairperson deploys the contract
  modifier onlyChairperson(_to) {
    require(voters[_to] != chairperson, "Not a valid Chairperson");
    _;
  }

  /// @notice Modifier to ensure voter has voted
  modifier haveVoted(address _to) {
    require(!voters[_to].voted, "Voter has already voted");
    _;
  }

  function giveRightToVote() {

  }

  function delegate() {
    
  }

  function vote() {
    
  }

  function winningProposal() {
    
  }

  function winnerName() {
    
  }

}
