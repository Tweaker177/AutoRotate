ARCHS = arm64 armv7 arm64e armv7s
TARGET = iphone:clang:11.2:8.0
#CFLAGS = -fobjc-arc
DEBUG = 0
include $(THEOS)/makefiles/common.mk

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
