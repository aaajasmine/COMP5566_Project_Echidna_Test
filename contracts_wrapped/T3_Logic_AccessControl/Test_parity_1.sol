pragma solidity ^0.4.9;
import "/share/benchmark/T3_Logic_AccessControl/parity_wallet_bug_1.sol";

contract TestParity is Wallet {
    // 属性：虽然 m_numOwners 不可见，但如果攻击者通过 initWallet 篡改了合约，
    // 原本的合约逻辑（比如转账）会失效或被重置。
    // 我们检查：合约是否依然处于“可预期状态”。
    function echidna_test_still_alive() public view returns (bool) {
        // 尝试检查一个公开的、不该改变的状态
        return isOwner(msg.sender); 
    }
}