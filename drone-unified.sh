#!bin/bash
#
# Copyright 2019, Najahiiii <najahiii@outlook.co.id>
# Copyright 2019, Dicky Herlambang "Nicklas373" <herlambangdicky5@gmail.com>
# Copyright 2016-2019, HANA-CI Build Project
#
# Clarity Kernel Builder Script || For Circle CI
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

# Let's make some option here
#
# Kernel Name Release
# 0 = CAF || 1 = Clarity || 2 = Clarity-10 || 3 = Clarity-Lave
#
# Kernel Type
# 0 = HMP || 1 = EAS
#
# Kernel Branch Relase
# 0 = BETA || 1 = Stable
#
# Kernel Android Version
# 0 = Pie || 1 = 10 || 2 = 9 - 10
#
# Kernel Codename
# 0 = Mido || 1 = Lavender
#
# Kernel Extend Defconfig
# 0 = Dev-Mido || 1 = Dev-Lave || 2 = Null
#
KERNEL_NAME_RELEASE="2"
KERNEL_TYPE="1"
KERNEL_BRANCH_RELEASE="1"
KERNEL_ANDROID_VERSION="1"
KERNEL_CODENAME="0"
KERNEL_EXTEND="2"

# Compiling For Mido // If mido was selected
if [ "$KERNEL_CODENAME" == "0" ];
	then
		# Create Temporary Folder
		mkdir TEMP

		if [ "$KERNEL_NAME_RELEASE" == "0" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b pie https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel
				git clone https://github.com/Nicklas373/AnyKernel3 --depth=1 -b caf/mido
		elif [ "$KERNEL_NAME_RELEASE" == "1" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b dev/toyama https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel
				git clone https://github.com/Nicklas373/AnyKernel3 --depth=1 -b mido
		elif [ "$KERNEL_NAME_RELEASE" == "2" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b dev/toyama-10 https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel
				git clone https://github.com/Nicklas373/AnyKernel3 --depth=1 -b yukina/10
		fi

		# Cloning Toolchains Repository
		git clone https://github.com/Nicklas373/clang --depth=1 -b test clang

# Compiling Repository For Lavender // If lavender was selected
elif [ "$KERNEL_CODENAME" == "1" ];
	then
		# Cloning Kernel Repository
		git clone --depth=1 -b toyama  https://github.com/Nicklas373/kernel_xiaomi_lavender kernel

		# Cloning Clang Repository
		git clone https://github.com/NusantaraDevs/clang --depth=1 -b dev/10.0 clang

		# Cloning AnyKernel Repository
		git clone https://github.com/Nicklas373/AnyKernel3 -b lavender

		# Create Temporary Folder
		mkdir TEMP
fi

# Kernel Enviroment
export ARCH=arm64
export LD_LIBRARY_PATH="$(pwd)/clang/bin/../lib:$PATH"
export KBUILD_BUILD_USER=Yukina
export KBUILD_BUILD_HOST=Drone-CI

# Kernel aliases
IMAGE="$(pwd)/kernel/out/arch/arm64/boot/Image.gz-dtb"
KERNEL="$(pwd)/kernel"
KERNEL_TEMP="$(pwd)/TEMP"
if [ "$KERNEL_CODENAME" == "0" ];
	then
		CODENAME="mido"
		KERNEL_CODE="Mido"
		TELEGRAM_DEVICE="Xiaomi Redmi Note 4x"
elif [ "$KERNEL_CODENAME" == "1" ];
	then
		CODENAME="lavender"
		KERNEL_CODE="Lavender"
		TELEGRAM_DEVICE="Xiaomi Redmi Note 7"
fi
if [ "$KERNEL_NAME_RELEASE" == "0" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r7"
		KERNEL_NAME="CAF"
		KERNEL_TYPE="HMP"
elif [ "$KERNEL_NAME_RELEASE" == "1" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r13"
		KERNEL_NAME="Clarity"
		KERNEL_TYPE="EAS"
elif [ "$KERNEL_NAME_RELEASE" == "2" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r13"
		KERNEL_NAME="Clarity"
 		KERNEL_TYPE="EAS"
elif [ "$KERNEL_NAME_RELEASE" == "3" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r10"
		KERNEL_NAME="Clarity"
		KERNEL_TYPE="EAS"
fi
KERNEL_SUFFIX="Kernel"
KERNEL_DATE="$(date +%Y%m%d-%H%M)"
if [ "$KERNEL_ANDROID_VERSION" == "0" ];
	then
		KERNEL_ANDROID_VER="9"
		KERNEL_TAG="P"
elif [ "$KERNEL_ANDROID_VERSION" == "1" ];
	then
		KERNEL_ANDROID_VER="10"
		KERNEL_TAG="Q"
elif [ "$KERNEL_ANDROID_VERSION" == "2" ];
	then
		KERNEL_ANDROID_VER="9-10"
		KERNEL_TAG="P-Q"
fi
if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
	then
		KERNEL_RELEASE="Stable"
elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
	then
		KERNEL_RELEASE="BETA"
fi

# Telegram aliases
TELEGRAM_BOT_ID="882513869:AAGu8crueJQlsvLWH119zugCGpIxEYwEHj0"
if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
	then
		TELEGRAM_GROUP_ID="-1001336252759"
elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
	then
		TELEGRAM_GROUP_ID="-1001251953845"
fi
TELEGRAM_FILENAME="${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_TAG}-${KERNEL_DATE}.zip"
export TELEGRAM_SUCCESS="CAADBQADhQcAAhIzkhBQ0UsCTcSAWxYE"
export TELEGRAM_FAIL="CAADBQADfgcAAhIzkhBSDI8P9doS7BYE"

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
curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendMessage -d chat_id=${TELEGRAM_GROUP_ID} -d "parse_mode=HTML" -d text="$(
            for POST in "${@}"; do
                echo "${POST}"
            done
          )"
}

# Telegram bot message || first notification
function bot_first_compile() {
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Start!</b>" \
	      "" \
 	      "<b>Build Status :</b><code> ${KERNEL_RELEASE} </code>" \
              "" \
              "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
              "" \
	      "<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
	      "" \
              "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1) </code>"
}

# Telegram bot message || complete compile notification
function bot_complete_compile() {
bot_env
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
    "" \
    "<b>New ${KERNEL_NAME} Kernel Build Is Available!</b>" \
    "" \
    "<b>Build Status :</b><code> ${KERNEL_RELEASE} </code>" \
    "" \
    "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
    "" \
    "<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
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
    "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \
    "" \
    "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)</code>" \
    "" \
    "<b>                         HANA-CI Build Project | 2016-2019                            </b>"
}

# Telegram bot message || success notification
function bot_build_success() {
bot_template  "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Success!</b>"
}

# Telegram bot message || failed notification
function bot_build_failed() {
bot_template "<b>|| Drone-CI Build Bot ||</b>" \
              "" \
	      "<b>${KERNEL_NAME} Kernel build Failed!</b>" \
              "" \
              "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)</code>"
}

# Telegram sticker message
function sendStick() {
	curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendSticker -d sticker="${1}" -d chat_id=$TELEGRAM_GROUP_ID &>/dev/null
}

# Compile Begin
function compile() {
	cd ${KERNEL}
	bot_first_compile
	cd ..
	if [ "$KERNEL_EXTEND" == "0" ];
		then
			sed -i -e 's/-友希那-Kernel-r13-LA.UM.8.6.r1-02300-89xx.0/-戸山-Kernel-r14-LA.UM.8.6.r1-02300-89xx.0/g'  ${KERNEL}/arch/arm64/configs/mido_defconfig
	elif [ "$KERNEL_EXTEND" == "1" ];
		then
			sed -i -e 's/-友希那-Kernel-r10-LA.UM.8.2.r1-04800-sdm660.0/-戸山-Kernel-r11-LA.UM.8.2.r1-04800-sdm660.0/g'  ${KERNEL}/arch/arm64/configs/lavender_defconfig
	fi
	START=$(date +"%s")
	make -s -C ${KERNEL} ${CODENAME}_defconfig O=out
	PATH="$(pwd)/clang/bin/:${PATH}" \
      	make -s -C ${KERNEL} -j$(nproc --all) O=out \
						CC=clang \
						CLANG_TRIPLE=aarch64-linux-gnu- \
        					CROSS_COMPILE=aarch64-linux-gnu- \
						CROSS_COMPILE_ARM32=arm-linux-gnueabi-
	if ! [ -a $IMAGE ];
		then
             		echo "kernel not found"
                	END=$(date +"%s")
                	DIFF=$(($END - $START))
			cd ${KERNEL}
                	bot_build_failed
			cd ..
			sendStick "${TELEGRAM_FAIL}"
                	exit 1
        	fi
        END=$(date +"%s")
        DIFF=$(($END - $START))
	cd ${KERNEL}
	bot_build_success
	cd ..
	sendStick "${TELEGRAM_SUCCESS}"
        cp ${IMAGE} AnyKernel3/Image.gz-dtb
	anykernel
	kernel_upload
}

# AnyKernel
function anykernel() {
	cd AnyKernel3
	make -j4
        mv Clarity-Kernel-${KERNEL_CODE}-signed.zip  ${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_TAG}-${KERNEL_DATE}.zip
}

# Upload Kernel
function kernel_upload(){
	cd ${KERNEL}
	bot_complete_compile
	if [ "$KERNEL_CODENAME" == "0" ];
		then
			cd ${KERNEL_TEMP}
	fi
	curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_TYPE}-${KERNEL_TAG}-${KERNEL_DATE}.zip"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
}

# Running
compile
