#!/bin/sh

echo "현재 빌드 인스턴스 정보:"

# 호스트 이름 출력
hostname=$(hostname)
echo "호스트 이름: $hostname"

# 운영 체제 정보 출력
os=$(uname -a)
echo "운영 체제 정보: $os"

# CPU 정보 출력
cpu_info=$(lscpu)
echo "CPU 정보: $cpu_info"

# 메모리 정보 출력
memory_info=$(free -m)
echo "메모리 정보: $memory_info"

# 디스크 사용량 출력
disk_usage=$(df -h)
echo "디스크 사용량: $disk_usage"

echo "Installing the mint..."
brew install mint

echo "Instaling the tuist..."
curl -Ls https://install.tuist.io | bash

cd ..
make all
