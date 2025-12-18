-- add modes: debug and release
add_rules("mode.debug", "mode.release")



 

	

-- git clone --depth 1 https://github.com/frang75/nappgui_src.git
-- cd nappgui_src
-- cmake -G Xcode -S . -B build
-- cmake --build build --config Debug



package("nappgui", function()
    add_urls("https://github.com/frang75/nappgui_src.git")
    add_versions("1.5.3", "8b83f3700788998794a6b790237c844fe34ebb3e")

    add_deps("cmake")

    if is_plat("linux") then
        add_deps("gtk3", { configs = { shared = true } })
        add_deps("apt::mesa-common-dev", "apt::libglu1-mesa-dev", "apt::libegl1-mesa-dev")
    end

    on_install(function (package)
        local gtk = package:dep("gtk3")
        if not gtk then raise("gtk3 not found!") end
        local gtklibdir = gtk:installdir()

        local configs = {}
        configs["CMAKE_BUILD_TYPE"] = package:config("mode") == "debug" and "Debug" or "Release"
        configs["NAPPGUI_SHARED"] = package:config("shared")
        configs["NAPPGUI_DEMO"] = false
        configs["NAPPGUI_WEB"] = false
        configs["CMAKE_PREFIX_PATH"] = gtklibdir
        --why cant it do this automatically? this project is awful and fuck cmake too
        local libs = {}

        for _, pkg in pairs(package:deps()) do
            libs[#libs+1] = "-L"..pkg:installdir("lib")
        end
        configs["CMAKE_SHARED_LINKER_FLAGS"] = table.concat(libs, " ")
        -- configs["CMAKE_SHARED_LINKER_FLAGS"] = table.concat({
        --     "-L"..gtk:installdir("lib"),
        --     "-L"..package:dep("pango"):installdir("lib"),
        --     "-L"..package:dep("cairo"):installdir("lib"),
        --     "-L"..package:dep("fri")
        -- }, " ")
        import("package.tools.cmake").install(package, configs)
        package:add("includedirs", "inc")
        package:add("linkdirs", "bin")
        package:add("rpathdirs", package:installdir("bin"))
    end)
end)

add_requires("nappgui", {
    configs = {
        shared = true,
        asan = false
    }
})

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

target("gelbooru-downloader", function()
    set_kind("binary")
    add_files("src/**.m|gui.m")
end)

target("gelbooru-downloader-gui", function()
    set_kind("binary")
    add_files("src/**.m|gelbooru-downloader.m")
    add_packages("nappgui")
end)

includes("nappgui-bindings")
