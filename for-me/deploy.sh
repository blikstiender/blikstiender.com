#!/usr/bin/env bash

# I'm including this deploy script since I use it - and it doesn't leak anything too substantial.
# It ain't the greatest deploy script out there, but it is mine.
#
# Maybe one day I'll also throw in some terraform for the S3 bucket + cloudfront dist I have for
# this website. One day...

set -euo

WEBSITE_DIR="$( cd "$(dirname "$0")/.." >/dev/null 2>&1 ; pwd -P )"
cd "$WEBSITE_DIR"


# generate the public dir
hugo

# Actual deploy! A funny name for my aws profile. Dw about it.
AWS_PROFILE=hummusalumnus hugo deploy
