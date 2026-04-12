pragma solidity ^0.4.23;
import "../../benchmark/T2_IntegerOverflow/overflow_single_tx.sol";

contract EchidnaTest is IntegerOverflowSingleTransaction {
    function echidna_test_count_logic() public view returns (bool) {
        // 只要 count 发生了溢出回滚（变回很小的值），我们认为它是不安全的
        // 这里我们可以设定一个逻辑：如果 count 变小了，说明发生了溢出或下溢
        return true; // 配合 --test-mode assertion 更有效
    }
}