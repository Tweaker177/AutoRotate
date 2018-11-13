ARCHS = armv7 arm64 armv7s 
TARGET = iphone:clang:9.0:9.4

include theos/makefiles/common.mk

BUNDLE_NAME = AutoRotate
AutoRotate_FILES = AutoRotate.mm
AutoRotate_INSTALL_PATH = /Library/PreferenceBundles
AutoRotate_FRAMEWORKS = UIKit
AutoRotate_PRIVATE_FRAMEWORKS = Preferences
AutoRotate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AutoRotate.plist$(ECHO_END)
