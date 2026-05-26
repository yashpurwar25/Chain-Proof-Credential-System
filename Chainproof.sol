// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainProof {
    address public admin;

    struct Credential {
        string title;
        uint8 level; // 1: Basic, 2: Intermediate, 3: Advanced
        uint256 timestamp;
    }

    // Mapping from user address to a list of their credentials
    mapping(address => Credential[]) public userCredentials;

    // Modifier to restrict functions to only the admin
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender; // The person who deploys the contract becomes the admin
    }

    /**
     * @dev Issues a credential to a member.
     * DESIGN DECISION: Duplicate Handling
     * I have implemented a check to prevent duplicate credential titles for the same user.
     * Reason: If a user is granted "Completed BlockBase" twice, it shouldn't inflate their 
     * trust score. This prevents "gaming" the system by issuing the same easy task repeatedly.
     */
    function issueCredential(address _member, string memory _title, uint8 _level) public onlyOwner {
        require(_level >= 1 && _level <= 3, "Level must be between 1 and 3");

        // Check for duplicates
        Credential[] storage creds = userCredentials[_member];
        for (uint i = 0; i < creds.length; i++) {
            require(keccak256(abi.encodePacked(creds[i].title)) != keccak256(abi.encodePacked(_title)), "Credential already issued");
        }

        userCredentials[_member].push(Credential({
            title: _title,
            level: _level,
            timestamp: block.timestamp
        }));
    }

    /**
     * @dev Returns the full list of credentials for a given address.
     */
    function getCredentials(address _user) public view returns (Credential[] memory) {
        return userCredentials[_user];
    }

    /**
     * @dev Computes the Trust Score.
     * FORMULA: Score = (Number of Credentials * 10) + (Sum of all Levels * 5)
     * REASONING: 
     * 1. Number of credentials rewards consistency and breadth of work (Quantity).
     * 2. Sum of levels rewards the difficulty of the tasks achieved (Quality).
     * This ensures a person with 1 Advanced credential (Score: 10+15=25) is 
     * ranked differently than someone with 3 Basic credentials (Score: 30+15=45).
     */
    function calculateTrustScore(address _user) public view returns (uint256) {
        Credential[] storage creds = userCredentials[_user];
        uint256 totalLevelScore = 0;
        
        for (uint i = 0; i < creds.length; i++) {
            totalLevelScore += creds[i].level;
        }
        
        return (creds.length * 10) + (totalLevelScore * 5);
    }

    /**
     * @dev Gated function based on Trust Score.
     * Threshold is set to 30. 
     */
    function accessGranted() public view returns (bool) {
        uint256 threshold = 30;
        if (calculateTrustScore(msg.sender) >= threshold) {
            return true;
        } else {
            revert("Access Denied: Trust score too low to enter the Matrix");
        }
    }

    /**
     * NON-TRANSFERABILITY EXPLANATION:
     * In a standard NFT contract, there is a 'transfer' function. 
     * I have intentionally omitted any function that allows moving a Credential 
     * from one address to another. Since the credentials are stored in a 
     * mapping tied to the address, they are "Soulbound."
     * WHY IT MATTERS: If credentials were transferable, someone could buy a 
     * "High Trust Score" from another user, destroying the integrity of the 
     * reputation system.
     */
}