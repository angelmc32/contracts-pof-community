//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CommunityBoundERC20 is ERC20, Ownable {
	uint256 public initialDrip = 23 * 10 ** 18;
	uint256 public dailyDrip = 10 * 10 ** 18;

	mapping(address => bool) public communityMembers;
	mapping(address => bool) public communityNftContracts;

	constructor() ERC20("Community Bound Token", "CBT") {}

	function addCommunityMember(
		address newMemberAddress_,
		address communityNftAddress_
	) public onlyOwner {
		require(communityNftContracts[communityNftAddress_]);
		require(
			IERC721(communityNftAddress_).balanceOf(newMemberAddress_) == 1
		);
		communityMembers[newMemberAddress_] = true;
		_mint(newMemberAddress_, initialDrip);
	}

	function addMultipleCommunityMembers(
		address[] memory members
	) public onlyOwner {
		for (uint256 i = 0; i < members.length; i++) {
			communityMembers[members[i]] = true;
		}
	}

	function adminMint(address to, uint256 amount) public onlyOwner {
		require(
			communityMembers[to],
			"CBT: Can mint only to community members"
		);
		_mint(to, amount);
	}

	function mint(address to, uint256 amount) public {
		require(
			communityMembers[to],
			"CBT: Can mint only to community members"
		);
		_mint(to, amount);
	}

	function transfer(
		address recipient,
		uint256 amount
	) public override returns (bool) {
		require(
			communityMembers[recipient],
			"CBT: Can transfer only to community members"
		);
		return super.transfer(recipient, amount);
	}

	function isCommunityMember(address member) public view returns (bool) {
		return communityMembers[member];
	}
}
