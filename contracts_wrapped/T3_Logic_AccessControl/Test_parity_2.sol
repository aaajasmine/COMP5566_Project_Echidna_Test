pragma solidity ^0.4.9;
import "/share/benchmark/T3_Logic_AccessControl/parity_wallet_bug_2.sol"; // 注意对应 bug_2

contract TestParity2 is Wallet {
    // 属性：初始部署者（tx.origin）应该永远是 Owner
    // 如果漏洞被触发，攻击者会通过 initWallet 把自己变成 Owner，从而把原 Owner 踢掉
    function echidna_test_i_am_still_owner() public view returns (bool) {
        // isOwner 是原合约的 public 方法，我们可以直接用
        return isOwner(tx.origin);
    }
}