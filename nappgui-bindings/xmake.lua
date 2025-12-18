target("nappgui-bindings", function()
    set_kind("static")

    add_headerfiles("include/(**.h)")
    add_files("src/**.m")

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

    add_includedirs("include", { public = true })
    add_packages("objfw", "nappgui", { public = true })
end)

target("nappgui-bindings-hello", function()
    set_kind("binary")
    add_deps("nappgui-bindings")
    add_files("examples/hello.m")
end)
