pragma solidity  ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
// import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


// Raffle__NotEnoughETHEntered()

abstract contract  Raffle is VRFConsumerBaseV2{
	uint256 private immutable i_entranceFee;
	address payable[] private s_players;
	event RaffleEnter(address indexed player);
	VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
	bytes32 private immutable i_gasLane;
	uint64 private immutable i_subscriptionid;
	uint private immutable i_callbackGasLimit;
	uint16 private constant REQUEST_CONFIRMATIONS=3;

	constructor(address vrfCoordinatorV2,uint256 entranceFee,bytes32 gasLane,uint64 subscriptionid,uint32 callBackGasLimit) 
	VRFConsumerBaseV2(vrfCoordinatorV2){
		i_entranceFee=entranceFee;
		i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinatorV2);
		i_gasLane=gasLane;
		i_subscriptionid=subscriptionid;
		i_callbackGasLimit=callBackGasLimit;
	}

	function enterRaffle() public payable{
		if(msg.value<i_entranceFee){
		}
		s_players.push(payable(msg.sender));
		emit RaffleEnter(msg.sender);

	}

	function requestRandomWinner()external {
		i_vrfCoordinator.requestRandomWords(
			i_gasLane,
			s_subscriptionid,
			REQUEST_CONFIRMATIONS,
			callbackGasLimit,
		
		);
	}


	// function fulfilRandomWords(uint256,uint256[] memory randomWords) internal override
	
	// {

	// }

	function getEntranceFee() public view returns (uint256){
		return i_entranceFee;
	}

	function getPlayer(uint256 index) public view returns(address){

	}

}