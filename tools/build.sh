#!/bin/bash

# Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Run pub get to fetch packages.
pub get

# Verify that the libraries are error and warning-free.
echo "Running dartanalyzer..."
dartanalyzer $DARTANALYZER_FLAGS lib/ bin/

# Verify that dartfmt has been run.
echo "Checking dartfmt..."
if [[ $(dartfmt -n --set-exit-if-changed lib/ test/ bin/) ]]; then
	echo "Failed dartfmt check. run: dartfmt -w lib/ test/ bin/"
	exit 1
fi

# Run the tests.
echo "Running tests..."
pub run test_coverage