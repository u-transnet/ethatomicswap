pragma solidity ^0.4.15;

contract AtomicSwap {

    enum State { Empty, Initiator, Participant }

    struct Swap {
        uint initTimestamp;
        uint refundTime;
        bytes20 hashedSecret;
        bytes32 secret;
        address from;
        address to;
        uint256 value;
        bool emptied;
        State state;
    }

    mapping(bytes32 => Swap) public swaps;
    
	event Refunded(uint _refundTime);
    event Redeemed(uint _redeemTime);
    event Participated(
        uint _initTimestamp,
        uint _refundTime,
        bytes20 _hashedSecret,
        address _from,
        address _to,
        uint256 _value
    );
	event Initiated(
		uint _initTimestamp,
    	uint _refundTime,
    	bytes20 _hashedSecret,
    	address _from,
    	address _to,
		uint256 _value
	);

    constructor() public {}

    function calculateSecretHash(bytes32 _secret) private pure returns(bytes20 secretHash){
        return ripemd160(abi.encodePacked(_secret));
    }

    function calculateContractHash(address _from, address _to, bytes20 _secretHash) private pure returns(bytes32 contractHash){
        return sha256(abi.encodePacked(_from, _to, _secretHash));
    }
    
	function isRefundable(bytes32 _contractHash) private{
	    require(block.timestamp > swaps[_contractHash].initTimestamp + swaps[_contractHash].refundTime);
	    require(swaps[_contractHash].emptied == false);
	}
	
	function isRedeemable(bytes32 _contractHash) private{
		require(block.timestamp < swaps[_contractHash].initTimestamp + swaps[_contractHash].refundTime);
	    require(swaps[_contractHash].emptied == false);
	}

    function isInitiated(bytes32 _contractHash) private{
        require(swaps[_contractHash].state != State.Empty);
    }
	
	function isNotInitiated(bytes32 _contractHash) private {
	    require(swaps[_contractHash].state == State.Empty);
	}

	function initiate(uint _refundTime, bytes20 _hashedSecret, address _to, uint _type)
        external
	    payable
	{
        bytes32 contractHash = calculateContractHash(msg.sender, _to, _hashedSecret);
        isNotInitiated(contractHash);

        State state = State(_type);
        require(State(_type) != State.Empty);

	    swaps[contractHash].refundTime = _refundTime;
	    swaps[contractHash].initTimestamp = block.timestamp;
	    swaps[contractHash].hashedSecret = _hashedSecret;
        swaps[contractHash].from = msg.sender;
	    swaps[contractHash].to = _to;
        swaps[contractHash].state = state;
        swaps[contractHash].value = msg.value;

        if(state == State.Initiator)
            emit Initiated(
                swaps[contractHash].initTimestamp,
                _refundTime,
                _hashedSecret,
                msg.sender,
                _to,
                msg.value
            );
        else
            emit Participated(
                swaps[contractHash].initTimestamp,
                _refundTime,
                _hashedSecret,
                msg.sender,
                _to,
                msg.value
            );
	}
	
	function redeem(bytes32 _secret, address _from)
        external
	{
        bytes32 contractHash = calculateContractHash(_from, msg.sender, calculateSecretHash(_secret));
        isInitiated(contractHash);
        isRedeemable(contractHash);

        swaps[contractHash].to.transfer(swaps[contractHash].value);
        swaps[contractHash].emptied = true;
        swaps[contractHash].secret = _secret;
        emit Redeemed(block.timestamp);
	}

	function refund(bytes20 _hashedSecret, address _to)
        external
	{
        bytes32 contractHash = calculateContractHash(msg.sender, _to, _hashedSecret);
        isInitiated(contractHash);
        isRefundable(contractHash);

        swaps[contractHash].from.transfer(swaps[contractHash].value);
        swaps[contractHash].emptied = true;
	    emit Refunded(block.timestamp);
	}
}