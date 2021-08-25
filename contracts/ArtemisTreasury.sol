pragma solidity >=0.4.21 <0.8.6;

contract ArtemisTreasury {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public nations;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        mapping(address => bool) isConfirmed;
        uint numConfirmations;
    }

    Transaction[] public transactions;

    /// @dev This modifier should require that msg.sender is an owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "This Nation is not the owner");
        _;
    }

    /// @dev It should require that the transaction at txIndex exists
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    /// @dev It should require that the transaction at txIndex is not yet executed
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction has already been executed");
        _;
    }

    /// @dev It should require that the transaction at txIndex is not yet confirmed by msg.sender
    modifier notConfirmed(uint _txIndex) {
        require(!transactions[_txIndex].isConfirmed[msg.sender], "Transaction has already been confirmed");
        _;
    }

    // Constructor initiates the nations involved in the Artemis program and the min. Confirmations for 
    // monetary policy decisions.
    constructor(address[] memory _nations, uint _numConfirmationsRequired) public {
        // 1. Validate that the _nation is not empty
        require(_nations.length > 0, "An owning Nation is required");

        // 2. Validate that _numConfirmationsRequired is greater than 0
        // 3. Validate that _numConfirmationsRequired is less than or equal to the number of _nations
        require(
            _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _nations.length,
            "Invalid number of required confirmations"
        );

        // 4. Set the state variables nations from the input _nations.
        for (uint i = 0; i < _nations.length; i++) {
            address nation = _nations[i];

            // - each nation should not be the zero address
            require(nation != address(0), "This Nation is an Invalid Owner");
            // - validate that the nations are unique using the isOwner mapping
            require(!isOwner[nation], "This Nation is not unique");

            isOwner[nation] = true;
            nations.push(nation);
        }
        // 5. Set the state variable numConfirmationsRequired from the input.
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    /// @notice Declares a payable fallback function
    /// @dev Should emit the Deposit event with msg.sender, msg.value and current amount of ether in the contract (address(this).balance)
    function () payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /// @notice Initiates the submission of a transaction in multi-sig wallet
    /// @dev New Transaction struct is appended to the transaction array state variable
    /// @param _to Address to submit transaction
    /// @param _value The value of the transaction amount
    /// @param _data Any meta data associated with the transaction
    /// @return An SubmitTransaction event is emitted at the end
    function submitTransaction(address _to, uint _value, bytes memory _data)
        public
        onlyOwner
    {
        // 2. Inside submitTransaction, create a new Transaction struct from the inputs
        //    and append it the transactions array
        //     - executed should be initialized to false
        //     - numConfirmations should be initialized to 0
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        // 3. Emit the SubmitTransaction event
        // - txIndex should be the index of the newly created transaction

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    /// @notice Confirms a Transaction
    /// @dev New Transaction struct is appended to the transaction array state variable
    /// @param _txIndex The txIndex to be confirmed
    /// @return An ConfirmTransaction event is emitted at the end
    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        // update the isConfirmed to true for msg.sender
        transaction.isConfirmed[msg.sender] = true;
        // increment numConfirmation by 1
        transaction.numConfirmations += 1;

        // emit ConfirmTransaction event for the transaction being confirmed
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    /// @notice Executes a Transaction
    /// @dev New Transaction struct is appended to the transaction array state variable
    /// @param _txIndex The txIndex to be confirmed
    /// @return An ExecuteTransaction event is emitted at the end
    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        // Should require that number of confirmations >= numConfirmationsRequired
        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        // Set executed to true
        transaction.executed = true;

        // Execute the transaction using the low level call method
        (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
        // Require that the transaction executed successfully
        require(success, "tx failed");

        // Emit ExecuteTransaction
        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    /// @notice Revokes a Transaction
    /// @dev New Transaction struct is appended to the transaction array state variable
    /// @param _txIndex The txIndex to be confirmed
    /// @return An RevokeTransaction event is emitted at the end    
    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        // Require that msg.sender has confirmed the transaction
        require(transaction.isConfirmed[msg.sender], "tx not confirmed");

        // Set isConfirmed to false for msg.sender
        transaction.isConfirmed[msg.sender] = false;
        // Decrement numConfirmations by 1
        transaction.numConfirmations -= 1;

        // Emit RevokeConfirmation
        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    /// @dev Self explainatory function
    function getNations() public view returns (address[] memory) {
        return nations;
    }

    /// @dev Self explainatory function
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    /// @dev Self explainatory function
    function getTransaction(uint _txIndex)
        public
        view
        returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    /// @dev Self explainatory function
    function isConfirmed(uint _txIndex, address _owner)
        public
        view
        returns (bool)
    {
        Transaction storage transaction = transactions[_txIndex];

        return transaction.isConfirmed[_owner];
    }
}
