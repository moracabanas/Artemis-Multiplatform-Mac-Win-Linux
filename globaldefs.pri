# Support debug and release builds from command line for CI
CONFIG += debug_and_release

# Ensure symbols are always generated
CONFIG += force_debug_info

# Disable asserts on release builds
CONFIG(release, debug|release) {
    DEFINES += NDEBUG
}

# Enable ASan for Linux or macOS
#CONFIG += sanitizer sanitize_address

# Enable ASan for Windows
#QMAKE_CFLAGS += -fsanitize=address
#QMAKE_CXXFLAGS += -fsanitize=address
#QMAKE_LFLAGS += -incremental:no -wholearchive:clang_rt.asan_dynamic-x86_64.lib -wholearchive:clang_rt.asan_dynamic_runtime_thunk-x86_64.lib

macx {
    # Qt 6.10's qyieldcpu.h calls __yield() on Apple Silicon without including
    # arm_acle.h first. Force-include a small compatibility header so both local
    # arm64 builds and universal packaging builds compile cleanly.
    QMAKE_CFLAGS += -include $$PWD/qt_arm_acle_compat.h
    QMAKE_CXXFLAGS += -include $$PWD/qt_arm_acle_compat.h
}
