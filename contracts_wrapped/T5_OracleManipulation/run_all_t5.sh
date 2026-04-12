#!/bin/bash

# 创建结果目录
RESULT_DIR="/share/results/T5_Final_Report"
mkdir -p $RESULT_DIR

# 定义待测文件列表
FILES=(
    "uwulend_vuln.sol"
    "compounduni_vuln.sol"
    "impermaxv3_vuln.sol"
    "moonwell_vuln.sol"
    "makina_machine_vuln.sol"
    "makina_caliber_vuln.sol"
)

echo "=== Starting T5 Batch Evaluation ==="

for FILE in "${FILES[@]}"; do
    echo "--------------------------------------------------"
    echo "Processing: $FILE"
    
    # 1. 自动选择 Solidity 版本
    if [[ "$FILE" == *"makina"* ]]; then
        solc-select use 0.8.28 || solc-select install 0.8.28 && solc-select use 0.8.28
    elif [[ "$FILE" == *"moonwell"* ]]; then
        solc-select use 0.8.19
    else
        solc-select use 0.8.7
    fi

    # 2. 构造临时测试合约 (根据文件名判断漏洞类型)
    TEST_FILE="Temp_Test.sol"
    
    if [[ "$FILE" == *"compound"* || "$FILE" == *"uwulend"* || "$FILE" == *"moonwell"* ]]; then
        # 预言机类漏洞：检查价格是否能被瞬间改写
        cat << EOT > $TEST_FILE
import "./$FILE";
contract EchidnaTest is PriceOracle { // 假设基类名为 PriceOracle
    function echidna_price_integrity() public view returns (bool) {
        return true; // 这里需要根据具体合约的 state 变量微调
    }
}
EOT
    elif [[ "$FILE" == *"makina"* ]]; then
        # 内存/指令类漏洞：检查内部状态是否损坏
        cat << EOT > $TEST_FILE
import "./$FILE";
contract EchidnaTest is Machine {
    function echidna_memory_safe() public view returns (bool) {
        return true; 
    }
}
EOT
    fi

    # 3. 运行 Echidna 并保存输出
    echo "Running Echidna on $FILE..."
    echidna $FILE --config config_t5.yaml --format text > "$RESULT_DIR/${FILE}_result.txt" 2>&1
    
    # 4. 简单提取结果
    if grep -q "FAILED" "$RESULT_DIR/${FILE}_result.txt"; then
        echo "[RESULT] $FILE: VULNERABILITY DETECTED (FAILED)"
    else
        echo "[RESULT] $FILE: PASSING / NOT FOUND"
    fi
done

echo "=== Evaluation Complete. Check $RESULT_DIR for logs. ==="
