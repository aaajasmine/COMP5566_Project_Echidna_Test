
pragma solidity ^0.5.0;
import "../../benchmark/T1_Reentrancy/reentrancy_insecure.sol";

contract EchidnaTest is Reentrancy_insecure {
    constructor() public payable {}

    function echidna_test_reentrancy() public view returns (bool) {
        // 判定：余额不应被抽干
        return address(this).balance > 0;
    }
}
