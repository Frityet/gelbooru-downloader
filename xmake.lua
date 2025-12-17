-- add modes: debug and release
add_rules("mode.debug", "mode.release")

set_policy("build.sanitizer.address", true)
set_policy("build.sanitizer.undefined", true)
set_policy("build.sanitizer.leak", true)

add_requires("objfw", {
    configs = {
        shared = true,
        tls = "openssl",
        debug = true
    }
})
set_languages("gnulatest")

add_packages("objfw")

add_mflags (
    "-Wall", "-Wextra", "-Werror",
    "-Wno-unused-function",
    "-Wno-unused-parameter"
)
add_mflags (
    "-Wanon-enum-enum-conversion",
    "-Wassign-enum",
    "-Wenum-conversion",
    "-Wenum-enum-conversion"
)
add_mflags (
    "-Wnull-dereference",
    "-Wnull-conversion",
    "-Wnullability-completeness",
    "-Wnullable-to-nonnull-conversion",
    "-Wno-missing-field-initializers",
    "-Wno-auto-var-id"
)
set_pmheader("src/common.h")
add_includedirs("src")

set_license("LGPL-3.0")

target("gelbooru-downloader")
    set_kind("binary")
    add_files("src/**.m")
