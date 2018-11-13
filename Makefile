ARCHS = armv7 arm64 armv7s 
TARGET = iphone:clang:9.0:9.4
#CFLAGS = -fobjc-arc
#THEOS_PACKAGE_DIR_NAME = debs
include theos/makefiles/common.mk

TWEAK_NAME = AutoRotate
AutoRotate_FILES = Tweak.xm
AutoRotate_FRAMEWORKS = UIKit Foundation 
AutoRotate_LDFLAGS += -Wl,-segalign,4000
AutoRotate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
SUBPROJECTS += AutoRotate
include $(THEOS_MAKE_PATH)/aggregate.mk
