#!/bin/sh
swift package clean
swift build -c release
cp .build/release/AmazingSpider /usr/local/bin/AmazingSpider
