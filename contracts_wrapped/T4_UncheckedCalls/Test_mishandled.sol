pragma solidity ^0.4.25;
import "./mishandled_source.sol";

contract MaliciousReceiver {
    // 恶意合约：拒绝任何转入，强制让 .send() 返回 false
    function() public payable {
        revert();
    }
}

contract TestSendBack is SendBack {
    MaliciousReceiver public attacker;

    // 修复点 1: 增加 payable，允许 Echidna 在部署时注入初始资金
    constructor() public payable {
        attacker = new MaliciousReceiver();
    }

    // 1. 给恶意合约在映射中增加余额
    function fundAttacker() public payable {
        if (msg.value > 0) {
            userBalances[address(attacker)] = msg.value;
        }
    }

    // 2. 触发提现逻辑
    function triggerWithdraw() public {
        // 强制以恶意合约的身份调用提现
        // 注意：由于原始合约 withdrawBalance 使用 msg.sender，
        // 我们在 Echidna 中需要确保 fuzzer 能够覆盖到这一步。
        withdrawBalance(); 
    }

    // Echidna 属性：
    // 如果 send 失败（向 attacker 转账失败），由于原始合约没检查返回值，
    // 它会静默通过。我们检查合约余额是否依然保留了这笔钱。
    function echidna_test_unchecked_result() public view returns (bool) {
        // 如果合约余额依然很大，说明钱没转出去，但函数却没报错，漏洞确认
        return address(this).balance < 0.5 ether;
    }
}
