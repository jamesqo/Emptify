#pragma once

#include <string>

namespace emptify
{
    std::string Utf16ToUtf8(const wchar_t* wide);
    std::string Utf16ToUtf8(const wchar_t* wide, size_t size);
    std::string Utf16ToUtf8(const std::wstring& wide);
}