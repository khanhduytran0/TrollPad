ARCHS := arm64 arm64e
TARGET := iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
# TARGET_CODESIGN = fastPathSign

TWEAK_NAME = TrollPad

TrollPad_FILES = Tweak.x TrollPadPrefs/NSUserDefaults+hook.x TPPrefsObserver.m
TrollPad_CFLAGS = -fobjc-arc
TrollPad_LDFLAGS = -lMobileGestalt
# TrollPad_PRIVATE_FRAMEWORKS = BoardServices SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TrollPadPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
