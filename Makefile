GO_EASY_ON_ME=1
FW_DEVICE_IP=apple-tv.local
export SDKVERSION=5.1
TOOL_NAME := TSSAgent
TSSAgent_FILES = Classes/TSSCategories.m Classes/JSONKit.m Classes/TSSHelper.m Classes/TSSCommon.m Classes/TSSManager.mm
TSSAgent_FILES += Classes/TSSWorker.m Classes/Reachability.m
TSSAgent_PACKAGE_TARGET_DIR = /usr/bin
TSSAgent_LDFLAGS = -framework CoreFoundation -framework IOKit -framework Foundation -framework SystemConfiguration -undefined dynamic_lookup #-framework BackRow

include theos/makefiles/common.mk
include theos/makefiles/tool.mk

after-TSSAgent-stage::
	$(FAKEROOT) chmod 6755 $(FW_STAGING_DIR)/usr/bin/TSSAgent
