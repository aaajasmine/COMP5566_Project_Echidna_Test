pragma solidity ^0.4.0;
import "./etherpot_source.sol";

contract BadBuyer {
    // 拒绝接收找零的以太币
    function() public payable { revert(); }
    
    function buy(address lottoAddr) public payable {
        // 买票，多给点钱触发找零
        lottoAddr.call.value(msg.value)();
    }
}

contract TestEtherpot is Lotto {
    BadBuyer public buyer;
    bool public breachDetected = false;

    constructor() public payable {
        buyer = new BadBuyer();
    }

    function testUncheckedRefund() public payable {
        // 买票，付 0.15 ether (票价 0.1 ether)，预期找零 0.05 ether
        buyer.buy.value(150000000000000000)(address(this));
        
        // 如果找零失败了（BadBuyer拒收），但合约没有报错回滚，说明存在漏洞
        breachDetected = true;
    }

    function echidna_test_etherpot_silent() public view returns (bool) {
        return breachDetected == false;
    }
}
