#!bin/bash
#
# Copyright 2019, Najahiiii <najahiii@outlook.co.id>
# Copyright 2019, Dicky Herlambang "Nicklas373" <herlambangdicky5@gmail.com>
#
# Clarity Kernel Builder Script || For Drone CI
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

# Only for debugging :p
ls

# Necessary :p
mkdir Clarity-TEMP

# Installing Dependencies
apt-get install -y ccache bc git-core gnupg build-essential zip curl make automake autogen autoconf autotools-dev libtool shtool python m4 gcc libtool zlib1g-dev dash

# Cloning Kernel Repository
git clone https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18 -b staging/yukina/r8 mido

# Pretty workaround :p
cd mido

# Clong toolchains and other repository
git clone https://github.com/Nicklas373/aosp-clang -b r365631b clang
git clone https://github.com/najahiiii/priv-toolchains -b non-elf/gcc-9.2.0/arm gcc_arm32
git clone https://github.com/najahiiii/priv-toolchains -b non-elf/gcc-9.2.0/arm64 gcc
git clone https://github.com/Nicklas373/AnyKernel3 -b mido
git clone https://github.com/fabianonline/telegram.sh -b master telegram

# Kernel Enviroment
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=Yukina
export KBUILD_BUILD_HOST=Drone-CI
export CLANG_PATH=$(pwd)/clang/bin
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CLANG_TRIPLE_ARM32=arm-linux-gnueabi-
export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=$(pwd)/gcc_arm32/bin/arm-linux-gnueabi-

# Kernel aliases
COMMIT="675a82520614507b3d24a13ea0b5a96089249488"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
KERNEL=$(pwd)
CODENAME="mido"
BRANCH="mido"
KERNEL_CODE="Mido"
KERNEL_REV="r8"
TELEGRAM_DEVICE="Xiaomi Redmi Note 4x"
KERNEL_NAME="Clarity"
KERNEL_SUFFIX="Kernel"
KERNEL_TYPE="EAS"
KERNEL_STATS="signed"
KERNEL_DATE="$(TZ=Asia/Jakarta date +'%Y%m%d-%H%M')"
TELEGRAM_BOT_ID="$token"
TELEGRAM_GROUP_ID="$chat_id"
TELEGRAM_FILENAME="${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_STATS}-${KERNEL_DATE}.zip"

# Import telegram bot environment
function bot_env() {
TELEGRAM_KERNEL_VER=$(cat ${KERNEL}/out/.config | grep Linux/arm64 | cut -d " " -f3)
TELEGRAM_UTS_VER=$(cat ${KERNEL}/out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
TELEGRAM_COMPILER_NAME=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILE_BY | cut -d '"' -f2)
TELEGRAM_COMPILER_HOST=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILE_HOST | cut -d '"' -f2)
TELEGRAM_TOOLCHAIN_VER=$(cat ${KERNEL}/out/include/generated/compile.h | grep LINUX_COMPILER | cut -d '"' -f2)
}

# Telegram Bot Service || Compiling Notification
function bot_template() {
$(pwd)/telegram/telegram -t ${TELEGRAM_BOT_ID} -c ${TELEGRAM_GROUP_ID} -H \
         "$(
            for POST in "${@}"; do
                echo "${POST}"
            done
          )"
}

# Telegram bot message || first notification
function bot_first_compile() {
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
              "<b>Clarity Kernel build Start!</b>" \
              "" \
              "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
              "" \
              "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1) </code>"
}

# Telegram bot message || complete compile notification
function bot_complete_compile() {
bot_env
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
    "" \
    "<b> New Clarity Kernel Build Is Available! </b>" \
    "" \
    "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
    "" \
    "<b>Filename :</b><code> ${TELEGRAM_FILENAME}</code>" \
    "" \
    "<b>Kernel Version:</b><code> Linux ${TELEGRAM_KERNEL_VER}</code>" \
    "" \
    "<b>Kernel Host:</b><code> ${TELEGRAM_COMPILER_NAME}@${TELEGRAM_COMPILER_HOST}</code>" \
    "" \
    "<b>Kernel Toolchain :</b><code> ${TELEGRAM_TOOLCHAIN_VER}</code>" \
    "" \
    "<b>UTS Version :</b><code> ${TELEGRAM_UTS_VER}</code>" \
    "" \
    "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>"
}

# Telegram bot message || success notification
function bot_build_success() {
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
              "<b>Clarity Kernel build Success!</b>" \
	      "" \
	      "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)"
}

# Telegram bot message || failed notification
function bot_build_failed() {
bot_template "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
              "<b>Clarity Kernel build Failed!</b>"
	      "" \
	      "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)"
}

# Compile Begin
function compile() {
	bot_first_compile
	START=$(date +"%s")
	make -s -C ${KERNEL} mido_defconfig
	make -s -C ${KERNEL} CC=clang CLANG_TRIPLE=${CLANG_TRIPLE} CLANG_TRIPLE_ARM32=${CLANG_TRIPLE_ARM32} CROSS_COMPILE=${CROSS_COMPILE} CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} -j$(nproc --all)
	if ! [ -a $IMAGE ]; then
                echo "kernel not found"
		bot_build_failed
                exit 1
        fi
	END=$(date +"%s")
	DIFF=$(($END - $START))
	bot_build_success
        cp ${IMAGE} AnyKernel3/Image.gz-dtb
	anykernel
	kernel_upload
}

# AnyKernel
function anykernel() {
        cd AnyKernel3
        make -j4
        mv Clarity-Kernel-${KERNEL_CODE}-signed.zip  ${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_STATS}-${KERNEL_DATE}.zip
	cd ..
	cd mido
}

# Upload Kernel
function kernel_upload(){
	bot_complete_compile
        $(pwd)/telegram/telegram -t ${TELEGRAM_BOT_ID} -c ${TELEGRAM_GROUP_ID} -f $(pwd)/AnyKernel3/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_STATS}-${KERNEL_DATE}.zip
	git --no-pager log --pretty=format:"%h - %s (%an)" --abbrev-commit ${COMMIT}..HEAD > git-changelog.txt
	$(pwd)/telegram/telegram -t ${TELEGRAM_BOT_ID} -c ${TELEGRAM_GROUP_ID} -f git-changelog.txt
}

# Running
compile
