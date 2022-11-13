pragma solidity  ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
// import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


// Raffle__NotEnoughETHEntered()

abstract contract  Raffle is VRFConsumerBaseV2{
	uint256 private immutable i_entranceFee;
	address payable[] private s_players;
	event RaffleEnter(address indexed player);

	constructor(address vrfCoordinatorV2,uint256 entranceFee) VRFConsumerBaseV2(vrfCoordinatorV2){
		i_entranceFee=entranceFee;
	}

	function enterRaffle() public payable{
		if(msg.value<i_entranceFee){
		}
		s_players.push(payable(msg.sender));
		emit RaffleEnter(msg.sender);

	}

	// function requestRandomWinner(){

	// }
	// function fulfilRandomWords(uint256,uint256[] memory randomWords) internal override
	
	// {

	// }

	function getEntranceFee() public view returns (uint256){
		return i_entranceFee;
	}

	function getPlayer(uint256 index) public view returns(address){

	}

}