#include <iostream>

#include <zlib.h>

int main()
{
    std::cout << zlibVersion() << '\n';

    return 0;
}