#pragma once

#include <stdexcept>

namespace emptify
{
    template <typename String>
    String& replace(String& s, const String& from, const String& to)
    {
        if (from.empty())
            throw std::invalid_argument("from cannot be an empty string!");
        size_t start = 0;
        while ((start = s.find(from, start)) != String::npos)
        {
            s.replace(start, from.length(), to);
            start += to.length();
        }
        return s;
    }
}