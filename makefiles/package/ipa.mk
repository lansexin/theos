ifeq ($(_THEOS_PACKAGE_FORMAT_LOADED),)
_THEOS_PACKAGE_FORMAT_LOADED := 1

_THEOS_IPA_PACKAGE_CONTROL_PATH := $(THEOS_PROJECT_DIR)/control
_THEOS_IPA_CAN_PACKAGE := $(if $(_THEOS_IPA_PACKAGE_CONTROL_PATH),$(_THEOS_TRUE),$(_THEOS_FALSE))
_THEOS_PACKAGE_INC_VERSION_PREFIX := -
_THEOS_PACKAGE_EXTRA_VERSION_PREFIX := +

_THEOS_IPA_HAS_IPABUILD := $(call __executable,zip)
ifneq ($(_THEOS_IPA_HAS_IPABUILD),$(_THEOS_TRUE))
internal-package-check::
	@echo "$(MAKE) package requires zip."; exit 1
endif

ifeq ($(_THEOS_IPA_CAN_PACKAGE),$(_THEOS_TRUE)) # Control file found (or layout directory found.)
THEOS_PACKAGE_NAME := $(shell grep -i "^Package:" "$(_THEOS_IPA_PACKAGE_CONTROL_PATH)" | cut -d' ' -f2-)
THEOS_PACKAGE_BASE_VERSION := $(shell grep -i "^Version:" "$(_THEOS_IPA_PACKAGE_CONTROL_PATH)" | cut -d' ' -f2-)

_THEOS_ESCAPED_PACKAGE_DIR = $(shell readlink -f $(shell pwd)/$(THEOS_PACKAGE_DIR))
_THEOS_IPA_PACKAGE_FILENAME = $(_THEOS_ESCAPED_PACKAGE_DIR)/$(THEOS_PACKAGE_NAME)_$(_THEOS_INTERNAL_PACKAGE_VERSION).ipa
internal-package::
	$(ECHO_NOTHING)cp -r $(THEOS_STAGING_DIR)/Applications $(THEOS_STAGING_DIR)/Payload; pushd $(THEOS_STAGING_DIR) &> /dev/null; zip -qru "$(_THEOS_IPA_PACKAGE_FILENAME)" Payload; popd &> /dev/null$(ECHO_END)

# This variable is used in package.mk
after-package:: __THEOS_LAST_PACKAGE_FILENAME = $(_THEOS_IPA_PACKAGE_FILENAME)

else # _THEOS_IPA_CAN_PACKAGE == 0
internal-package::
	@echo "$(MAKE) package requires you to have a control file in the project root describing the package."; exit 1

endif # _THEOS_IPA_CAN_PACKAGE
endif # _THEOS_PACKAGE_FORMAT_LOADED
