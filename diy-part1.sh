#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
# ======================================================
# 【定制】针对 ZBT Z8102AX (eMMC 改装版) 的修改
# ======================================================

# 1. 修改设备配置文件，注入 eMMC 启动必需的内核命令行参数
if [ -f target/linux/mediatek/image/mt7981.mk ]; then
    echo "🔧 正在为 ZBT-Z8102AX (eMMC) 修改内核启动参数..."
    sed -i '/define Device\/zbtlink_zbt-z8102ax/,/^endef/ {
        /KERNEL_CMDLINE/d
        /^endef/i \  KERNEL_CMDLINE := earlycon=uart8250,mmio32,0x11002000 console=ttyS0,115200n8 root=PARTLABEL=rootfs rootfstype=squashfs,f2fs
    }' target/linux/mediatek/image/mt7981.mk
    echo "✅ 内核参数修改完成。"
fi

# 2. 确保必要的内核模块被选中（硬件支持）
echo "CONFIG_PACKAGE_kmod-mmc=y" >> .config  # eMMC 驱动
echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config
echo "CONFIG_PACKAGE_kmod-fs-f2fs=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config

# 3. 添加 5G 模组 (FM350-GL / RM500Q-GL) 必备支持
echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y" >> .config  # QMI 协议驱动
echo "CONFIG_PACKAGE_kmod-usb-serial-option=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-net-rndis=y" >> .config     # RNDIS 协议
echo "CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y" >> .config  # MBIM 协议
echo "CONFIG_PACKAGE_uqmi=y" >> .config                   # QMI 管理工具
echo "CONFIG_PACKAGE_usbutils=y" >> .config               # lsusb 工具

# 4. 添加管理和界面软件（推荐）
echo "CONFIG_PACKAGE_luci=y" >> .config                    # 网页管理界面
echo "CONFIG_PACKAGE_luci-proto-modemmanager=y" >> .config # 5G 界面支持
echo "CONFIG_PACKAGE_modemmanager=y" >> .config            # 移动宽带管理
echo "✅ 设备专属配置已添加。"
# ======================================================
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
