//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CommunityBoundERC20 is ERC20, Ownable {
	uint256 public initialDrip = 23 * 10 ** 18;
	uint256 public dailyDrip = 10 * 10 ** 18;
	uint256 public coolingPeriod = 15;

	address private _admin;

	mapping(address => bool) public communityMembers;
	mapping(address => bool) public communityWallets;
	mapping(address => bool) public communityNftContracts;
	mapping(address => uint256) public timeUntilDailyDrip;

	constructor(address adminAddress_) ERC20("Community Bound Token", "CBT") {
		_admin = adminAddress_;
		communityMembers[_admin] = true;
	}

	function getDrip() external onlyMembers {
		address sender = _msgSender();
		require(
			block.timestamp >= timeUntilDailyDrip[sender],
			"CBT: Cooling period has not ended"
		);
		_mint(sender, dailyDrip);
		timeUntilDailyDrip[sender] = block.timestamp + coolingPeriod;
	}

	function addCommunity(
		address newCommunityWallet_,
		address communityNftAddress_
	) public onlyOwner {
		communityWallets[newCommunityWallet_] = true;
		communityNftContracts[communityNftAddress_] = true;
	}

	function addCommunityMember(
		address newMemberAddress_,
		address communityNftAddress_
	) public {
		require(
			communityNftContracts[communityNftAddress_],
			"CBT: Community Membership does not exist"
		);
		require(
			IERC721(communityNftAddress_).balanceOf(newMemberAddress_) == 1,
			"CBT: Caller does not own Community Membership"
		);
		communityMembers[newMemberAddress_] = true;
		_mint(newMemberAddress_, initialDrip);
	}

	function ownerRemoveCommunityMember(
		address memberAddress_
	) public onlyOwner {
		communityWallets[memberAddress_] = false;
	}

	function removeCommunity(
		address communityWallet_,
		address communityNftAddress_
	) public onlyOwner {
		communityWallets[communityWallet_] = false;
		communityNftContracts[communityNftAddress_] = false;
	}

	function communityMint(address to, uint256 amount) public onlyCommunities {
		require(
			communityMembers[to],
			"CBT: Can mint only to community members"
		);
		_mint(to, amount);
	}

	function mint(address to, uint256 amount) public onlyMembers {
		require(
			communityMembers[to],
			"CBT: Can mint only to community members"
		);
		_mint(to, amount);
	}

	function transfer(
		address to,
		uint256 amount
	) public override returns (bool) {
		require(
			communityMembers[to],
			"CBT: Can transfer only to community members"
		);
		return super.transfer(to, amount);
	}

	modifier onlyAdmin() {
		require(_msgSender() == _admin);
		_;
	}

	modifier onlyMembers() {
		require(isCommunityMember(_msgSender()), "CBT: Only Members");
		_;
	}

	modifier onlyCommunities() {
		require(
			isCommunityWallet(_msgSender()),
			"CBT: Only Communities Multisig"
		);
		_;
	}

	function isCommunityWallet(
		address communityWallet_
	) public view returns (bool) {
		return communityWallets[communityWallet_];
	}

	function isCommunityMember(
		address memberAddress_
	) public view returns (bool) {
		return communityMembers[memberAddress_];
	}

	// Dev functions, remove for deployment

	function adminAddCommunity(
		address newCommunityWallet_,
		address communityNftAddress_
	) public onlyAdmin {
		communityWallets[newCommunityWallet_] = true;
		communityNftContracts[communityNftAddress_] = true;
	}

	function adminAddCommunityMember(address newMemberAddress_) public {
		communityMembers[newMemberAddress_] = true;
		_mint(newMemberAddress_, initialDrip);
	}

	function adminMint(address to, uint256 amount) public onlyAdmin {
		require(
			communityMembers[to],
			"CBT: Can mint only to community members"
		);
		_mint(to, amount);
	}
}
