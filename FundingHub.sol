pragma solidity 0.4.8;
contract DeployProject {
   struct project {
       uint goal;
       uint deadline;
   }
      uint projId;
      mapping (uint => project) projects;
   function DeployProject (uint goal, uint deadline) {
      var proj = projects[projId];
      proj.goal = goal;
      proj.deadline = deadline;
     }
}
contract CrowdFunding {
    struct Funding {
        address projectaddr;
        uint contributed;
        uint goal;
        uint deadline;
        uint num_contributions;
        mapping(uint => Contribution) contributions;
    }
    struct Contribution {
        address contributor;
        uint amount;
    }

    uint nextFundId;
    mapping(uint256 => Funding) Fundings;
		function FundingHub() {
	//		owner= msg.sender;
 	 }

    // create and deploy new contract
    function CreateProject(uint goal, uint deadline) returns (uint id) {
        var Fund = Fundings[nextFundId];
        Fund.projectaddr = new DeployProject(goal, deadline);
        nextFundId ++;
        id = nextFundId;
    }

    // Contribute to the Funding
    function contribute(uint256 FundId) payable {
        var Fund = Fundings[FundId];
        if (Fund.deadline == 0) // check for non-existing Fund
            return;
        Fund.contributed += msg.value;
        var contribution = Fund.contributions[Fund.num_contributions];
        contribution.contributor = msg.sender;
        contribution.amount = msg.value;
        Fund.num_contributions++;
    }

    // Check full contribution and send the funding to owner project
    function Payout(uint256 FundId) returns (bool reached) {
        var Fund = Fundings[FundId];
        if (Fund.deadline > 0 && Fund.contributed >= Fund.goal) {
            if (!Fund.projectaddr.send(Fund.contributed)) throw; //send fund to project owner
            for (uint i = 0; i < Fund.num_contributions; ++i)
                delete Fund.contributions[i]; // zero out its members
          //  delete Fund; //vince bug. don't know how to del struct
            reached = true;
        }
    }

    // Check Expiry and return all funds to individual contributor

    function Refund(uint FundId) returns (bool expired) {
        expired = false;
        var Fund = Fundings[FundId];
        if (Fund.deadline > 0 && block.timestamp > Fund.deadline) {
            for (uint i = 0; i < Fund.num_contributions; ++i) {
                if (!Fund.contributions[i].contributor.send(Fund.contributions[i].amount)) throw;
                delete Fund.contributions[i];
            }
        //    delete Fund; // vince find bug
            expired = true;
        }
    }

    function getContributedAmount(uint FundId) returns (uint amount) {
        amount = Fundings[FundId].contributed;
    }
}
