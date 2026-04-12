pragma solidity ^0.4.22;
import "/share/benchmark/T3_AccessControl/phishable.sol";

contract TestPhishable is Phishable {
    // 构造时给自己打点钱作为诱饵
    constructor() Phishable(msg.sender) public payable {}

    // 属性：只要钱还在，说明 withdrawAll 的 tx.origin 检查没被绕过
    function echidna_test_money_staying() public view returns (bool) {
        return address(this).balance > 0;
    }
}