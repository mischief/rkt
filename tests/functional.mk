$(call setup-stamp-file,FTST_FUNCTIONAL_TESTS_STAMP,/functional-tests)
$(call setup-tmp-dir,FTST_TMPDIR)

FTST_TEST_TMP := $(FTST_TMPDIR)/test-tmp
FTST_IMAGE_DIR := $(FTST_TMPDIR)/image
FTST_IMAGE_ROOTFSDIR := $(FTST_IMAGE_DIR)/rootfs
FTST_IMAGE := $(FTST_TMPDIR)/rkt-inspect.aci
FTST_IMAGE_MANIFEST_SRC := $(MK_SRCDIR)/image/manifest
FTST_IMAGE_MANIFEST := $(FTST_IMAGE_DIR)/manifest
FTST_IMAGE_TEST_DIRS := $(FTST_IMAGE_ROOTFSDIR)/dir1 $(FTST_IMAGE_ROOTFSDIR)/dir2 $(FTST_IMAGE_ROOTFSDIR)/bin
FTST_ACE_MAIN_IMAGE_DIR := $(FTST_TMPDIR)/ace-main
FTST_ACE_MAIN_IMAGE := $(FTST_TMPDIR)/rkt-ace-validator-main.aci
FTST_ACE_MAIN_IMAGE_MANIFEST_SRC := Godeps/_workspace/src/github.com/appc/spec/ace/image_manifest_main.json
FTST_ACE_MAIN_IMAGE_MANIFEST := $(FTST_ACE_MAIN_IMAGE_DIR)/manifest
FTST_ACE_SIDEKICK_IMAGE_DIR := $(FTST_TMPDIR)/ace-sidekick
FTST_ACE_SIDEKICK_IMAGE := $(FTST_TMPDIR)/rkt-ace-validator-sidekick.aci
FTST_ACE_SIDEKICK_IMAGE_MANIFEST_SRC := Godeps/_workspace/src/github.com/appc/spec/ace/image_manifest_sidekick.json
FTST_ACE_SIDEKICK_IMAGE_MANIFEST := $(FTST_ACE_SIDEKICK_IMAGE_DIR)/manifest
FTST_INSPECT_BINARY := $(FTST_TMPDIR)/inspect
FTST_ACI_INSPECT := $(FTST_IMAGE_ROOTFSDIR)/inspect
FTST_ACE_BINARY := $(FTST_TMPDIR)/ace-validator
FTST_ECHO_SERVER_BINARY := $(FTST_TMPDIR)/echo-socket-activated
FTST_ACI_ECHO_SERVER := $(FTST_IMAGE_ROOTFSDIR)/echo-socket-activated
FTST_EMPTY_IMAGE_DIR := $(FTST_TMPDIR)/empty-image
FTST_EMPTY_IMAGE_ROOTFSDIR := $(FTST_EMPTY_IMAGE_DIR)/rootfs
FTST_EMPTY_IMAGE := $(FTST_TMPDIR)/rkt-empty.aci
FTST_EMPTY_IMAGE_MANIFEST_SRC := $(MK_SRCDIR)/empty-image/manifest
FTST_EMPTY_IMAGE_MANIFEST := $(FTST_EMPTY_IMAGE_DIR)/manifest

TOPLEVEL_CHECK_STAMPS += $(FTST_FUNCTIONAL_TESTS_STAMP)
TOPLEVEL_FUNCTIONAL_CHECK_STAMPS += $(FTST_FUNCTIONAL_TESTS_STAMP)
INSTALL_FILES += $(FTST_IMAGE_MANIFEST_SRC):$(FTST_IMAGE_MANIFEST):- $(FTST_INSPECT_BINARY):$(FTST_ACI_INSPECT):- $(FTST_EMPTY_IMAGE_MANIFEST_SRC):$(FTST_EMPTY_IMAGE_MANIFEST):- $(FTST_ACE_MAIN_IMAGE_MANIFEST_SRC):$(FTST_ACE_MAIN_IMAGE_MANIFEST):- $(FTST_ACE_SIDEKICK_IMAGE_MANIFEST_SRC):$(FTST_ACE_SIDEKICK_IMAGE_MANIFEST):- $(FTST_ECHO_SERVER_BINARY):$(FTST_ACI_ECHO_SERVER):-
CREATE_DIRS += $(FTST_IMAGE_DIR) $(FTST_EMPTY_IMAGE_DIR) $(FTST_EMPTY_IMAGE_ROOTFSDIR) $(FTST_IMAGE_TEST_DIRS) $(FTST_TEST_TMP)
INSTALL_DIRS += $(FTST_IMAGE_ROOTFSDIR):0755
CLEAN_FILES += $(FTST_IMAGE) $(FTST_ECHO_SERVER_BINARY) $(FTST_INSPECT_BINARY) $(FTST_EMPTY_IMAGE) $(FTST_IMAGE_ROOTFSDIR)/dir1/file $(FTST_IMAGE_ROOTFSDIR)/dir2/file $(FTST_ACE_BINARY)
CLEAN_DIRS += $(FTST_IMAGE_ROOTFSDIR)/dir1 $(FTST_IMAGE_ROOTFSDIR)/dir2 $(FTST_IMAGE_ROOTFSDIR)/bin
CLEAN_SYMLINKS += $(FTST_IMAGE_ROOTFSDIR)/inspect-link $(FTST_IMAGE_ROOTFSDIR)/bin/inspect-link-bin

$(call forward-vars,$(FTST_FUNCTIONAL_TESTS_STAMP), \
	RKT_BINARY ACTOOL FTST_IMAGE FTST_EMPTY_IMAGE FTST_TEST_TMP ABS_GO \
	FTST_INSPECT_BINARY GO_ENV GO_TEST_FUNC_ARGS REPO_PATH \
	FTST_ACE_MAIN_IMAGE FTST_ACE_SIDEKICK_IMAGE)
$(FTST_FUNCTIONAL_TESTS_STAMP): $(FTST_IMAGE) $(FTST_EMPTY_IMAGE) $(ACTOOL_STAMP) $(RKT_STAMP) $(FTST_ACE_MAIN_IMAGE) $(FTST_ACE_SIDEKICK_IMAGE) | $(FTST_TEST_TMP)
	$(VQ) \
	$(call vb,vt,GO TEST,$(REPO_PATH)/tests) \
	sudo RKT="$(RKT_BINARY)" ACTOOL="$(ACTOOL)" RKT_INSPECT_IMAGE="$(FTST_IMAGE)" RKT_EMPTY_IMAGE="$(FTST_EMPTY_IMAGE)" RKT_ACE_MAIN_IMAGE=$(FTST_ACE_MAIN_IMAGE) RKT_ACE_SIDEKICK_IMAGE=$(FTST_ACE_SIDEKICK_IMAGE) FUNCTIONAL_TMP="$(FTST_TEST_TMP)" INSPECT_BINARY="$(FTST_INSPECT_BINARY)" $(GO_ENV) "$(ABS_GO)" test -timeout 30m -v $(GO_TEST_FUNC_ARGS) $(REPO_PATH)/tests

$(call forward-vars,$(FTST_IMAGE), \
	FTST_IMAGE_ROOTFSDIR ACTOOL FTST_IMAGE_DIR)
$(FTST_IMAGE): $(FTST_IMAGE_MANIFEST) $(FTST_ACI_INSPECT) $(FTST_ACI_ECHO_SERVER) | $(FTST_IMAGE_TEST_DIRS)
	$(VQ) \
	set -e; \
	$(call vb,v2,GEN,$(call vsp,$(FTST_IMAGE_ROOTFSDIR)/dir1/file)) \
	echo -n dir1 >$(FTST_IMAGE_ROOTFSDIR)/dir1/file; \
	$(call vb,v2,GEN,$(call vsp,$(FTST_IMAGE_ROOTFSDIR)/dir2/file)) \
	echo -n dir2 >$(FTST_IMAGE_ROOTFSDIR)/dir2/file; \
	$(call vb,v2,LN SF,/inspect $(call vsp,$(FTST_IMAGE_ROOTFSDIR)/inspect-link)) \
	ln -sf /inspect $(FTST_IMAGE_ROOTFSDIR)/inspect-link; \
	$(call vb,v2,LN SF,/inspect $(call vsp,$(FTST_IMAGE_ROOTFSDIR)/bin/inspect-link-bin)) \
	ln -sf /inspect $(FTST_IMAGE_ROOTFSDIR)/bin/inspect-link-bin; \
	$(call vb,vt,ACTOOL,$(call vsp,$@)) \
	"$(ACTOOL)" build --overwrite --owner-root "$(FTST_IMAGE_DIR)" "$@"

# variables for makelib/build_go_bin.mk
BGB_STAMP := $(FTST_FUNCTIONAL_TESTS_STAMP)
BGB_BINARY := $(FTST_INSPECT_BINARY)
BGB_PKG_IN_REPO := $(call go-pkg-from-dir)/inspect
BGB_GO_FLAGS := -a -installsuffix cgo
BGB_ADDITIONAL_GO_ENV := CGO_ENABLED=0

include makelib/build_go_bin.mk

BGB_STAMP := $(FTST_FUNCTIONAL_TESTS_STAMP)
BGB_BINARY := $(FTST_ACE_BINARY)
BGB_PKG_IN_REPO := Godeps/_workspace/src/github.com/appc/spec/ace
BGB_GO_FLAGS := -a -installsuffix cgo
BGB_ADDITIONAL_GO_ENV := CGO_ENABLED=0

include makelib/build_go_bin.mk

$(call forward-vars,$(FTST_EMPTY_IMAGE), \
	ACTOOL FTST_EMPTY_IMAGE_DIR)
$(FTST_EMPTY_IMAGE): $(FTST_EMPTY_IMAGE_MANIFEST) | $(FTST_EMPTY_IMAGE_ROOTFSDIR)
	$(VQ) \
	$(call vb,vt,ACTOOL,$(call vsp,$@)) \
	"$(ACTOOL)" build --overwrite "$(FTST_EMPTY_IMAGE_DIR)" "$@"

# variables for makelib/build_go_bin.mk
BGB_STAMP := $(FTST_FUNCTIONAL_TESTS_STAMP)
BGB_BINARY := $(FTST_ECHO_SERVER_BINARY)
BGB_PKG_IN_REPO := $(call go-pkg-from-dir)/echo-socket-activated
BGB_GO_FLAGS := -a -installsuffix cgo
BGB_ADDITIONAL_GO_ENV := CGO_ENABLED=0

include makelib/build_go_bin.mk

# 1 - image
# 2 - aci directory
# 3 - ace validator
define FTST_GENERATE_ACE_IMAGE

$$(call forward-vars,$1,ACTOOL)
$1: $2/manifest $2/rootfs/ace-validator | $2/rootfs/opt/acvalidator
	$$(VQ) \
	$$(call vb,vt,ACTOOL,$$(call vsp,$$@)) \
	"$$(ACTOOL)" build --overwrite "$2" "$1"

CREATE_DIRS += $2 $$(call dir-chain,$2,rootfs/opt/acvalidator)
INSTALL_FILES += $3:$2/rootfs/ace-validator:-
CLEAN_FILES += $1
endef

$(eval $(call FTST_GENERATE_ACE_IMAGE,$(FTST_ACE_MAIN_IMAGE),$(FTST_ACE_MAIN_IMAGE_DIR),$(FTST_ACE_BINARY)))
$(eval $(call FTST_GENERATE_ACE_IMAGE,$(FTST_ACE_SIDEKICK_IMAGE),$(FTST_ACE_SIDEKICK_IMAGE_DIR),$(FTST_ACE_BINARY)))

$(call undefine-namespaces,FTST)
