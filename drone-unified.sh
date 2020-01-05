#!bin/bash
#
# Copyright 2019, Najahiiii <najahiii@outlook.co.id>
# Copyright 2019, alanndz <alanmahmud0@gmail.com>
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
# 0 = CAF || 1 = Clarity
#
# Kernel Type
# 0 = HMP || 1 = EAS || 2 = EAS-UC
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
# Kernel Compiler
# 0 = Clang 10.0.0 (Nusantara Clang) || 1 = Clang 10.0.0 (Pendulum Clang) || 2 = Clang 10.0.3 + (GCC 10.0-0155-221219 Non-elf 32/64)
#
KERNEL_NAME_RELEASE="1"
KERNEL_TYPE="1"
KERNEL_BRANCH_RELEASE="0"
KERNEL_ANDROID_VERSION="2"
KERNEL_CODENAME="1"
KERNEL_EXTEND="1"
KERNEL_COMPILER="0"

# Compiling For Mido // If mido was selected
if [ "$KERNEL_CODENAME" == "0" ];
	then
		# Create Temporary Folder
		mkdir TEMP

		if [ "$KERNEL_NAME_RELEASE" == "0" ];
			then
				# Clone kernel & other repositories earlier
				git clone --depth=1 -b pie https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel
				git clone --depth=1 -b mido-10 https://github.com/Nicklas373/AnyKernel3

				# Define Kernel Scheduler
				KERNEL_SCHED="HMP"

		elif [ "$KERNEL_NAME_RELEASE" == "1" ];
			then
				if [ "$KERNEL_TYPE" == "1" ];
					then
						# Clone kernel & other repositories earlier
						git clone --depth=1 -b dev/kasumi https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel

						# Define Kernel Scheduler
                                                KERNEL_SCHED="EAS"
				elif [ "$KERNEL_TYPE" == "2" ];
					then
						# Clone kernel & other repositories earlier
						git clone --depth=1 -b dev/kasumi-uc https://github.com/Nicklas373/kernel_xiaomi_msm8953-3.18-2 kernel

						# Define Kernel Scheduler
						KERNEL_SCHED="EAS-UC"
				fi

				# Detect Android Version earlier and clone AnyKernel depend on android version
				if [ "$KERNEL_ANDROID_VERSION" == "0" ];
					then
						git clone --depth=1 -b mido https://github.com/Nicklas373/AnyKernel3
				else
						git clone --depth=1 -b mido-10 https://github.com/Nicklas373/AnyKernel3
				fi
		fi
# Compiling Repository For Lavender // If lavender was selected
elif [ "$KERNEL_CODENAME" == "1" ];
	then
		# Cloning Kernel Repository
		git clone --depth=1 -b dev/eas-upstream https://github.com/Nicklas373/kernel_xiaomi_lavender kernel

		# Cloning AnyKernel Repository
		git clone --depth=1 -b lavender https://github.com/Nicklas373/AnyKernel3

		# Create Temporary Folder
		mkdir TEMP
fi
if [ "$KERNEL_COMPILER" == "0" ];
	then
		# Cloning Toolchains Repository
		git clone https://github.com/NusantaraDevs/clang --depth=1 -b dev/10.0 clang
elif [ "$KERNEL_COMPILER" == "1" ];
	then
		# Cloning Toolchains Repository
		git clone --depth=1 https://github.com/Haseo97/Clang-10.0.0 -b clang-10.0.0 clang
elif [ "$KERNEL_COMPILER" == "2" ];
	then
		# Cloning Toolchains Repository
		git clone https://github.com/NusantaraDevs/clang -b ndk-clang-10 clang
		git clone https://github.com/najahiiii/priv-toolchains -b non-elf/gcc-10.0.0/arm gcc_arm32
		git clone https://github.com/najahiiii/priv-toolchains -b non-elf/gcc-10.0.0/arm64 gcc
fi
# Kernel Enviroment
export ARCH=arm64
if [ "$KERNEL_COMPILER" == "0" ];
	then
		export LD_LIBRARY_PATH="$(pwd)/clang/bin/../lib:$PATH"
elif [ "$KERNEL_COMPILER" == "1" ];
	then
		export CLANG_PATH=$(pwd)/clang/bin
		export PATH=${CLANG_PATH}:${PATH}
		export LD_LIBRARY_PATH="$(pwd)/clang/bin/../lib:$PATH"
elif [ "$KERNEL_COMPILER" == "2" ];
	then
		export CLANG_PATH=$(pwd)/clang/bin
                export PATH=${CLANG_PATH}:${PATH}
		export LD_LIBRARY_PATH="$(pwd)/clang/bin/../lib:$PATH"
                export CLANG_TRIPLE=aarch64-linux-gnu-
                export CLANG_TRIPLE_ARM32=arm-linux-gnueabi-
                export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-gnu-
		export CROSS_COMPILE_ARM32=$(pwd)/gcc_arm32/bin/arm-linux-gnueabi-
fi
export KBUILD_BUILD_USER=Kasumi
export KBUILD_BUILD_HOST=Drone-CI
# Kernel aliases
if [ "$KERNEL_CODENAME" == "0" ];
	then
		IMAGE="${pwd}/kernel/out/arch/arm64/boot/Image.gz-dtb"
		KERNEL="kernel"
		KERNEL_TEMP="${pwd}/TEMP"
		CODENAME="mido"
		KERNEL_CODE="Mido"
		TELEGRAM_DEVICE="Xiaomi Redmi Note 4x"
elif [ "$KERNEL_CODENAME" == "1" ];
	then
		IMAGE="${pwd}/kernel/out/arch/arm64/boot/Image.gz"
		DTB="${pwd}/kernel/out/arch/arm64/boot/dts/qcom"
		KERNEL="kernel"
		KERNEL_TEMP="${pwd}/TEMP"
		CODENAME="lavender"
		KERNEL_CODE="Lavender"
		TELEGRAM_DEVICE="Xiaomi Redmi Note 7"
fi
if [ "$KERNEL_TYPE" == "0" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r10"
		KERNEL_NAME="CAF"
		COMMIT="1db74c045cad77d37578b457e11f7637e749fb84"
elif [ "$KERNEL_TYPE" == "1" ];
	then
		if [ "$KERNEL_CODENAME" == "0" ];
			then
				# Kernel extend aliases
				KERNEL_REV="r16"
				KERNEL_NAME="Clarity"
				COMMIT="e70d423a7638e5cd991782f61c7631835d5ce1f2"
		elif [ "$KERNEL_CODENAME" == "1" ];
			then
				 # Kernel extend aliases
				KERNEL_REV="r13"
				KERNEL_NAME="Clarity"
		fi
elif [ "$KERNEL_TYPE" == "2" ];
	then
		# Kernel extend aliases
		KERNEL_REV="r15"
		KERNEL_NAME="Clarity"
		COMMIT="a1c8138bb049459b4ce33f5e9fbae1559af59e2d"
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
TELEGRAM_BOT_ID=${tg_bot_id}
if [ "$KERNEL_BRANCH_RELEASE" == "1" ];
	then
		TELEGRAM_GROUP_ID=${tg_channel_id}
elif [ "$KERNEL_BRANCH_RELEASE" == "0" ];
	then
		TELEGRAM_GROUP_ID=${tg_group_id}
fi

TELEGRAM_FILENAME="${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip"
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
              "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
              "<b>Kernel Scheduler :</b><code> ${KERNEL_SCHED} </code>" \
	      "<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
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
    "<b>Device :</b><code> ${TELEGRAM_DEVICE} </code>" \
    "<b>Android Version :</b><code> ${KERNEL_ANDROID_VER} </code>" \
    "" \
    "<b>Kernel Scheduler :</b><code> ${KERNEL_SCHED} </code>" \
    "<b>Kernel Version:</b><code> Linux ${TELEGRAM_KERNEL_VER}</code>" \
    "<b>Kernel Host:</b><code> ${TELEGRAM_COMPILER_NAME}@${TELEGRAM_COMPILER_HOST}</code>" \
    "<b>Kernel Toolchain :</b><code> ${TELEGRAM_TOOLCHAIN_VER}</code>" \
    "" \
    "<b>Filename :</b><code> ${TELEGRAM_FILENAME}</code>" \
    "<b>UTS Version :</b><code> ${TELEGRAM_UTS_VER}</code>" \
    "<b>Latest commit :</b><code> $(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \
    "" \
    "<b>Compile Time :</b><code> $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)</code>" \
    "" \
    "<b>                         HANA-CI Build Project | 2016-2020                            </b>"
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
	if [ "$KERNEL_CODENAME" == "0" ];
		then
			cd ${KERNEL}
			bot_first_compile
			if [ "$KERNEL_EXTEND" == "0" ];
				then
					if [ "$KERNEL_TYPE" == "1" ] ;
						then
							sed -i -e 's/-友希那-Kernel-r16-LA.UM.8.6.r1-02900-89xx.0/-戸山-Kernel-r16-LA.UM.8.6.r1-02900-89xx.0/g'  ${KERNEL}/arch/arm64/configs/mido_defconfig
					elif [ "$KERNEL_TYPE" == "2" ];
						then
							sed -i -e 's/-友希那-Kernel-r16-UC-LA.UM.8.6.r1-02900-89xx.0/-戸山-Kernel-r16-UC-LA.UM.8.6.r1-02900-89xx.0/g' ${KERNEL}/arch/arm64/configs/mido_defconfig
					fi
			fi
			START=$(date +"%s")
			make -s -C ${KERNEL} ${CODENAME}_defconfig O=out
		if [ "$KERNEL_COMPILER" == "0" ];
			then
				PATH="$(pwd)/clang/bin/:${PATH}" \
        			make -s -C ${KERNEL} -j$(nproc --all) O=out \
								CC=clang \
								CLANG_TRIPLE=aarch64-linux-gnu- \
		        					CROSS_COMPILE=aarch64-linux-gnu- \
								CROSS_COMPILE_ARM32=arm-linux-gnueabi-
		elif [ "$KERNEL_COMPILER" == "1" ];
			then
				PATH="$(pwd)/clang/bin/:${PATH}" \
				make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
								CC=clang \
                                                                CLANG_TRIPLE=aarch64-linux-gnu- \
								CROSS_COMPILE=aarch64-linux-gnu- \
								CROSS_COMPILE_ARM32=arm-linux-gnueabi-
		elif [ "$KERNEL_COMPILER" == "2" ];
			then
				PATH="$(pwd)/clang/bin/:${PATH}" \
				make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
								CC=clang \
								CLANG_TRIPLE=${CLANG_TRIPLE} \
								CROSS_COMPILE=${CROSS_COMPILE} \
								CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32}
		fi
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
        		cp ${IMAGE} AnyKernel3
			anykernel
			kernel_upload
	elif [ "$KERNEL_CODENAME" == "1" ];
		then
			cd ${KERNEL}
			bot_first_compile
			if [ "$KERNEL_EXTEND" == "1" ];
				then
					sed -i -e 's/-友希那-Kernel-r13-LA.UM.8.2.r1-05100-sdm660.0/-戸山-Kernel-r13-LA.UM.8.2.r1-05100-sdm660.0/g' ${KERNEL}/arch/arm64/configs/lavender_defconfig
			fi
        		START=$(date +"%s")
        		make -s -C ${KERNEL} ${CODENAME}_defconfig O=out
	if [ "$KERNEL_COMPILER" == "2" ];
		then
			PATH="$(pwd)/clang/bin/:${PATH}" \
			make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
							CC=clang \
							CLANG_TRIPLE=${CLANG_TRIPLE} \
							CROSS_COMPILE=${CROSS_COMPILE} \
							CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32}
	else
			PATH="$(pwd)/clang/bin:${PATH}" \
			make -C ${KERNEL} -j$(nproc --all) -> ${KERNEL_TEMP}/compile.log O=out \
							CC=clang \
							CLANG_TRIPLE=aarch64-linux-gnu- \
							CROSS_COMPILE=aarch64-linux-gnu- \
							CROSS_COMPILE_ARM32=arm-linux-gnueabi-
	fi
			if ! [ -a $IMAGE ];
				then
                			echo "kernel not found"
                			END=$(date +"%s")
                			DIFF=$(($END - $START))
                			bot_build_failed
					sendStick "${TELEGRAM_FAIL}"
               				exit 1
        		fi
       			END=$(date +"%s")
        		DIFF=$(($END - $START))
			bot_build_success
			sendStick "${TELEGRAM_SUCCESS}"
        		cp ${IMAGE} AnyKernel3/kernel
			cp ${DTB}/*.dtb AnyKernel3/dtbs
			anykernel
			kernel_upload
	fi
}

# AnyKernel
function anykernel() {
	cd AnyKernel3
	make -j4
	mv Clarity-Kernel-${KERNEL_CODE}-signed.zip  ${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip
}

# Upload Kernel
function kernel_upload(){
	cd ${KERNEL}
	git --no-pager log --pretty=format:"%h - %s (%an)" --abbrev-commit ${COMMIT}..HEAD > git.log
	cp git.log ${KERNEL_TEMP}
	bot_complete_compile
	curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/${KERNEL_NAME}-${KERNEL_SUFFIX}-${KERNEL_CODE}-${KERNEL_REV}-${KERNEL_SCHED}-${KERNEL_TAG}-${KERNEL_DATE}.zip"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
	curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/git.log" https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument
	curl -F chat_id=${TELEGRAM_GROUP_ID} -F document="@${KERNEL_TEMP}/compile.log"  https://api.telegram.org/bot${TELEGRAM_BOT_ID}/sendDocument}
}

# Running
compile
