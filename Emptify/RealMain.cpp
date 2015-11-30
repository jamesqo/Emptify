#include "RealMain.hpp"

#include "Defer.hpp"
#include "Option.hpp"
#include "StringConversions.hpp"
#include "StringOperations.hpp"

#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <shlobj.h>
#include <windows.h>

namespace emptify
{
    constexpr auto Usage() noexcept // C++11 is pretty chill.
    {
        return R"(Emptify is a CLI script that empties your Recycle Bin.

Usage:
    emptify
    Clears the Recycle Bin.
or
    emptify --on-startup
    Run Emptify each time your computer starts.)";
    }

    template <typename Stream>
    int PrintAndExit(Stream& out, const std::string& message, int errorCode)
    {
        out << message << std::endl;
        return errorCode;
    }

    Option ParseOption(const std::string& opt) noexcept
    {
        // Screw C++ for not having switch-case for strings
        if (opt == "-?") return Option::Help;
        if (opt == "-h") return Option::Help;
        if (opt == "--help") return Option::Help;
        if (opt == "--on-startup") return Option::Startup;
        return Option::Unknown;
    }

    std::string GetErrorMessage(int errorCode)
    {
        wchar_t* buffer = nullptr;
        size_t length = FormatMessageW(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            nullptr,
            errorCode,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            reinterpret_cast<wchar_t*>(&buffer), // Nope, not a typo. Win32 is just fucking weird.
            0,
            nullptr);
        DEFER(LocalFree(buffer));
        return Utf16ToUtf8(buffer, length);
    }

    std::string ProcessPath()
    {
        wchar_t path[MAX_PATH];
        int result = GetModuleFileNameW(nullptr, path, MAX_PATH);
        if (result == 0) // GetModuleFileName returns 0 on failure
            throw std::runtime_error("GetModuleFileNameW failed: " + GetErrorMessage(GetLastError()));
        return Utf16ToUtf8(path);
    }

    std::string StartupFolderPath()
    {
        wchar_t* buffer = nullptr;
        int result = SHGetKnownFolderPath(
            FOLDERID_Startup,
            0,
            nullptr, 
            &buffer);
        DEFER(CoTaskMemFree(static_cast<void*>(buffer)));
        if (FAILED(result))
            throw std::runtime_error("SHGetKnownFolderPath failed! Error code: " + result);
        return Utf16ToUtf8(buffer);
    }

    std::string ShortcutPath()
    {
        return StartupFolderPath() + "\\Emptify.url";
    }

    int NormalMain()
    {
        int result = SHEmptyRecycleBinW(
            nullptr,
            nullptr,
            SHERB_NOCONFIRMATION |
            SHERB_NOPROGRESSUI |
            SHERB_NOSOUND);

        if (SUCCEEDED(result) ||
            result == E_UNEXPECTED) // already empty
        {
            return 0;
        }

        throw std::runtime_error("SHEmptyRecycleBinW failed! Error code: " + result);
    }

    int StartupMain()
    {
        // Create a shortcut to this in Startup so
        // we run whenever the computer turns on.
        std::string here = ProcessPath();
        std::string there = ShortcutPath();

        std::ofstream out(there);
        out << "[InternetShortcut]" << std::endl;
        out << "URL=file:///" << replace<std::string>(here, "\\", "/");
        
        return 0;
    }

    int RealMain(int argc, char* argv[])
    {
        try
        {
            if (argc > 2)
                return PrintAndExit(std::cerr, Usage(), 1);
            if (argc == 2)
            {
                auto opt = ParseOption(argv[1]);
                switch (opt)
                {
                    case Option::Help:
                        return PrintAndExit(std::cout, Usage(), 0);
                    case Option::Startup:
                        return StartupMain();
                    default:
                        return PrintAndExit(std::cerr, Usage(), 3);
                }
            }

            return NormalMain();
        }
        catch (const std::exception& e)
        {
            return PrintAndExit(std::cerr, e.what(), 2);
        }
    }
}