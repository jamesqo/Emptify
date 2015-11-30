#include "StringConversions.hpp"

#include <codecvt>
#include <locale>

namespace emptify
{
    std::string Utf16ToUtf8(const wchar_t* wide)
    {
        return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(wide);
    }

    std::string Utf16ToUtf8(const wchar_t* wide, size_t size)
    {
        return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(wide, wide + size);
    }

    std::string Utf16ToUtf8(const std::wstring& wide)
    {
        return std::wstring_convert<std::codecvt_utf8<wchar_t>>().to_bytes(wide);
    }
}