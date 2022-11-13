pragma solidity  ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
// import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


// Raffle__NotEnoughETHEntered()

abstract contract  Raffle is VRFConsumerBaseV2{
	uint256 private immutable i_entranceFee;
	address payable[] private s_players;
	event RaffleEnter(address indexed player);
	event RequestedRaffleWinner(uint256 indexed requestId);
	event WinnerPicked(address indexed winner);

	VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
	bytes32 private immutable i_gasLane;
	uint64 private immutable i_subscriptionid;
	uint32 private immutable i_callbackGasLimit;
	uint16 private constant REQUEST_CONFIRMATIONS=3;
	uint32 private constant NUM_WORDS=1;


	address private s_recentWinner;

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
		uint256 requestId=i_vrfCoordinator.requestRandomWords(
			i_gasLane,
			i_subscriptionid,
			REQUEST_CONFIRMATIONS,
			i_callbackGasLimit,
			NUM_WORDS
		);
		emit RequestedRaffleWinner(requestId);
	}


	function fulfillRandomWords(uint256,uint256[] memory randomWords) internal override
	{
		uint256 WinnerIndex=randomWords[0] % s_players.length;
		address payable recentWinner=s_players[WinnerIndex];
		s_recentWinner=recentWinner;
		(bool success, )=recentWinner.call{value:address(this).balance}("");
		if(!success){
			// revert Raffle_TransferFailed();
		}
		emit WinnerPicked(recentWinner);
	}

	function getEntranceFee() public view returns (uint256){
		return i_entranceFee;
	}

	function getPlayer(uint256 index) public view returns(address){

	}

	function getRecentWinner() public view returns(address){
		return s_recentWinner;
	}

}