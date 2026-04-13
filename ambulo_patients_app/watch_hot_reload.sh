#!/bin/bash

# Check if 'entr' is installed
if ! command -v entr &> /dev/null; then
    echo "Error: 'entr' is not installed."
    echo "To install it, run: brew install entr"
    exit 1
fi

PID_FILE="/tmp/flutter.pid"

# Check if the flutter PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "Error: Flutter PID file not found at $PID_FILE"
    echo "Please run your flutter app with the --pid-file flag:"
    echo "  flutter run --pid-file $PID_FILE"
    exit 1
fi

FLUTTER_PID=$(cat "$PID_FILE")

echo "Hot Reload Watcher Started."
echo "Watching 'lib/' directory. Will send hot reload signal to Flutter process $FLUTTER_PID on save."

# Watch Dart files in lib/ and send SIGUSR1 to the flutter process on change
find lib -name "*.dart" | entr -p kill -SIGUSR1 "$FLUTTER_PID"
