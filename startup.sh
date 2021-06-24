#!/bin/bash

#Kill any existing Xorg servers:
killall Xorg || true
echo "killing existing Xorg Server"
sleep 2

#Defining Variables:
memory_offset="0"
clock_offset="-100"
fan_speed="80"
pwr_limit="190"

#Query the amount of GPUs in this node:
gpu_num="$(nvidia-smi -L | wc -l)"

#Run the coolbits script:
nvidia-xconfig -a --force-generate --allow-empty-initial-configuration --cool-bits=28 --no-sli --connected-monitor="DFP-0" #--separate-x-screens

# starting the X server virtual display:
X :0 &
sleep 3
export DISPLAY=:0
sleep 5
xset -dpms
xset s off
xhost +

# Enabling persistence mode makes sure that the driver doesn't get unloaded.
nvidia-smi -pm ENABLED

nvidia-settings -a GPUOverclockingState=1

#Setting the values for all the cards
n=0
while [ $n -lt "$gpu_num" ];
do
	sudo nvidia-smi -i $n -pl $pwr_limit
	nvidia-settings -c :0 -a "[gpu:${n}]/GPUMemoryTransferRateOffsetAllPerformanceLevels=$memory_offset" -a "[gpu:${n}]/GpuPowerMizerMode=1" -a "[gpu:${n}]/GPUGraphicsClockOffset[3]=$clock_offset"
	let n=n+1
done


# Kill the X server that we started.
killall Xorg || true

#Run nsfminer
screen -S "mine" -U -d -m /home/mikka/mining-startup/nsfminer -P stratum://0x2095505977009337dD2Dce83bc8baEc15427Db3A.node1@eu1.ethermine.org:4444

#Run Pheonixminer
#/home/mikka/ethereum-quickstart/phoenixminer/PhoenixMiner -pool ssl://eu1.ethermine.org:5555 -pool2 ssl://us1.ethermine.org:5555 -wal 0x2095505977009337dD2Dce83bc8baEc15427Db3A.node1 -proto 3

#Run Ethminer:
#./ethminer/ethminer -P stratums://0x2095505977009337dD2Dce83bc8baEc15427Db3A.node001@eu1.ethermine.org:5555 -G
#export PATH=$PATH:/opt/rocm/bin:/opt/rocm/rocprofiler/bin:/opt/rocm/opencl/bin

#restart the script every 4 hours in case it has lost internet:
sleep 4h
systemctl restart startup
