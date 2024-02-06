ARCHS := arm64 arm64e
TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME := rootless

include $(THEOS)/makefiles/common.mk
# TARGET_CODESIGN = fastPathSign

TWEAK_NAME = TrollPad

TrollPad_FILES = Tweak.x
TrollPad_CFLAGS = -fobjc-arc
TrollPad_PRIVATE_FRAMEWORKS = BoardServices SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
