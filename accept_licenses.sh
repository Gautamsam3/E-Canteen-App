#!/bin/bash

# This script accepts Android SDK licenses to avoid manual intervention
echo "Accepting Android SDK licenses..."
yes | flutter doctor --android-licenses
echo "All licenses should now be accepted."
