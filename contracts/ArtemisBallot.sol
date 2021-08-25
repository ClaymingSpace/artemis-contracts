// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @notice This is an off-chain voting contract
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
    chairperson = msg.sender;
    // 2. Chairperson must have a weight of 1
    voters[chairperson].weight = 1;
    // 3. Create Proposal objects to be added to the dynamic proposals array
    for (uint i = 0; i < proposalNames.length; i++) {
      proposals.push(
        Proposal(
          {
            name: proposalNames[i],
            voteCount: 0
          }
        )
      );
    }
  }

  /// @notice Modifier to ensure only chairperson deploys the contract
  modifier onlyChairperson(address _to) {
    require(chairperson != msg.sender, "Not a valid Chairperson");
    _;
  }

  /// @notice Modifier to ensure voter has voted
  modifier haveVoted(address _to) {
    require(!voters[_to].voted, "Voter has already voted");
    _;
  }

  function giveRightToVote() {
    // If the first argument of `require` evaluates
    // to `false`, execution terminates and all
    // changes to the state and to Ether balances
    // are reverted.
    // This used to consume all gas in old EVM versions, but
    // not anymore.
    // It is often a good idea to use `require` to check if
    // functions are called correctly.
    // As a second argument, you can also provide an
    // explanation about what went wrong.
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
