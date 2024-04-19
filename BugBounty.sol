// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract BugBounty {
    
    struct Reports {
        bool status;
        string bug;
    }

    struct Bounty {
        address creator;
        string url;
        string name;
        string description;
        uint amount;
        bool isActive;
        address[] testerAddress;
        mapping(address => bool) testers;
        mapping(address => string[]) reportedBugs;
    }
    
    mapping(uint => Bounty) public bounties;
    uint public bountyCount;
    
    event BountyCreated(uint indexed id, address indexed creator, string url, string name, string description, uint amount);
    event BugReported(uint indexed bountyId, address indexed tester, string bugDescription);
    event BountyResolved(uint indexed bountyId, address indexed tester, uint reward);
    
    function createBounty(string memory _url, string memory _name, string memory _description, uint _amount) external payable  {
        require(_amount > 0, "Bounty amount must be greater than 0");
        bountyCount++;
        Bounty storage newBounty = bounties[bountyCount];
        newBounty.creator = msg.sender;
        newBounty.url = _url;
        newBounty.name = _name;
        newBounty.description = _description;
        newBounty.amount = _amount;
        newBounty.isActive = true;
        newBounty.testerAddress;
        
        emit BountyCreated(bountyCount, msg.sender, _url, _name, _description, _amount);
    }
    
    function reportBug(uint _bountyId, string memory _bugDescription) external {
        require(bounties[_bountyId].isActive, "Bounty is not active");
        require(bounties[_bountyId].testers[msg.sender], "Only testers can report bugs");
        // require(!bounties[_bountyId].reportedBugs[msg.sender], "Bug already reported by this tester");

        // Reports memory  newReport =  Reports(true, _bugDescription);
        bounties[_bountyId].reportedBugs[msg.sender].push(_bugDescription);
        emit BugReported(_bountyId, msg.sender, _bugDescription);
    }
    
    function updateBountyStatus(uint _bountyId, bool _isActive) external {
        require(msg.sender == bounties[_bountyId].creator, "Only creator can update bounty status");
        
        bounties[_bountyId].isActive = _isActive;
    }
    
    function resolveBug(uint _bountyId, address _tester) external {
        require(msg.sender == bounties[_bountyId].creator, "Only creator can resolve bugs");
        // require(bounties[_bountyId].reportedBugs[_tester], "Bug not reported by this tester");
        
        uint reward = bounties[_bountyId].amount;
        payable(_tester).transfer(reward*10**18);
        emit BountyResolved(_bountyId, _tester, reward);
    }
    
    function enrollAsTester(uint _bountyId) external {
        require(bounties[_bountyId].isActive, "Bounty is not active");
        require(!bounties[_bountyId].testers[msg.sender], "Already enrolled as tester");
       
        bounties[_bountyId].testerAddress.push(msg.sender);

        bounties[_bountyId].testers[msg.sender] = true;
    }

    function getTesters(uint _bountyId) view external returns(address[] memory)  {
        return bounties[_bountyId].testerAddress ;
    }

    function getTesterReports (uint _bountyId, address _tester) view external returns(string[] memory)  {
        return bounties[_bountyId].reportedBugs[_tester];
    }

    function getBugsReportedByAllTesters(uint _bountyId) external view returns (string[] memory) {
        require(bounties[_bountyId].isActive, "Bounty is not active");

        uint totalBugs = 0;
        for (uint i = 0; i < bounties[_bountyId].testerAddress.length; i++) {
            address tester = bounties[_bountyId].testerAddress[i];
            totalBugs += bounties[_bountyId].reportedBugs[tester].length;
        }

        string[] memory allBugs = new string[](totalBugs);
        
        uint index = 0;
        for (uint i = 0; i < bounties[_bountyId].testerAddress.length; i++) {
            address tester = bounties[_bountyId].testerAddress[i];
            string[] memory currentReport = bounties[_bountyId].reportedBugs[tester];
            for (uint j = 0; j < currentReport.length; j++) {
                allBugs[index] = currentReport[j];
                index++;
            }
        }
        
        return allBugs;
    }

}
