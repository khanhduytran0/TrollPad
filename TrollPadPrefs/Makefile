include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TrollPad

$(BUNDLE_NAME)_FILES = DBSMultitaskingContinuousExposeController+hook.x NSUserDefaults+hook.x TPPRootListController.m
$(BUNDLE_NAME)_FRAMEWORKS = UIKit CydiaSubstrate
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
