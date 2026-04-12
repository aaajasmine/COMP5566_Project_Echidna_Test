#!/bin/bash

# 1. 对应你 D 盘 benchmark 文件夹的镜像路径
SOURCE_DIR="/share/benchmark/T6_BusinessLogic"
RESULT_DIR="/share/results/T6_BusinessLogic"
CONFIG_PATH="/share/contracts_wrapped/T5_OracleManipulation/config_t5.yaml"

mkdir -p $RESULT_DIR
mkdir -p /share/scripts

echo "--- 正在进入 T6 业务逻辑目录 ---"
# 这里脚本会自动帮你完成切换路径的操作
cd $SOURCE_DIR || { echo "错误: 找不到目录 $SOURCE_DIR"; exit 1; }

# 2. 识别所有漏洞合约
FILES=$(ls *vuln.sol 2>/dev/null)
if [ -z "$FILES" ]; then
    echo "错误: 在 $SOURCE_DIR 中未发现 *vuln.sol 文件。"
    echo "请确认你的挂载路径是否包含这些文件。"
    exit 1
fi

echo "--- 发现文件: $FILES ---"

for FILE in $FILES; do
    echo "--------------------------------------------------"
    echo "正在分析合约: $FILE"
    
    # 根据文件名自动匹配版本（处理大小写）
    LOW_FILE=$(echo "$FILE" | tr '[:upper:]' '[:lower:]')
    if [[ "$LOW_FILE" == *"laxo"* ]]; then VERSION="0.8.20"
    elif [[ "$LOW_FILE" == *"alkemi"* ]]; then VERSION="0.6.2"
    elif [[ "$LOW_FILE" == *"sharwa"* ]]; then VERSION="0.8.10"
    elif [[ "$LOW_FILE" == *"synap"* ]]; then VERSION="0.8.10"
    else VERSION="0.8.0"
    fi
    
    solc-select use $VERSION 2>/dev/null || (solc-select install $VERSION && solc-select use $VERSION)
    
    # 提取合约名
    CONTRACT_NAME=$(grep -m 1 "contract " $FILE | awk '{print $2}' | sed 's/{//g')
    
    # 生成包装层
    TEST_FILE="Echidna_T6_${FILE}"
    cat << EOT > $TEST_FILE
import "./$FILE";
contract EchidnaTest is $CONTRACT_NAME {
    // 基础 Invariant
    function echidna_test_alive() public view returns (bool) {
        return true; 
    }
}
EOT

    echo "Echidna 正在运行..."
    echidna $TEST_FILE --config $CONFIG_PATH --format text > "$RESULT_DIR/${FILE}_report.txt" 2>&1
    echo "[OK] $FILE 报告已生成。"
done

echo "--- T6 测试全部完成！ ---"
