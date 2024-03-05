ARCHS := arm64 arm64e
TARGET := iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
# TARGET_CODESIGN = fastPathSign

TWEAK_NAME = TrollPadSB TrollPadUI

TrollPadSB_FILES = TweakSB.x TrollPadPrefs/NSUserDefaults+hook.x TPPrefsObserver.m
TrollPadSB_CFLAGS = -fobjc-arc
TrollPadSB_LDFLAGS = -lMobileGestalt
# TrollPad_PRIVATE_FRAMEWORKS = BoardServices SpringBoard

TrollPadUI_FILES = TweakUI.x
TrollPadUI_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TrollPadPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
