#!/bin/bash

echo "🧪 运行 MoonJQ 功能测试"
echo "=========================="

# 进入项目目录
cd /home/pingguomiaomiao/Desktop/moonjq

echo ""
echo "📋 运行基础功能测试..."
moon run cmd/test test

echo ""
echo "🔍 运行功能状态检查..."
moon run cmd/test feature_test

echo ""
echo "🧪 运行真实功能测试..."
moon run cmd/test real_test

echo ""
echo "✅ 所有测试完成！"
