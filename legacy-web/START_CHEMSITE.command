#!/bin/zsh

set -e

PROJECT_DIR="${0:A:h}"
cd "$PROJECT_DIR"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "ChemSite requires Node.js 20.19 or newer."
  echo "Download it from https://nodejs.org/ and run this file again."
  read "REPLY?Press Enter to close..."
  exit 1
fi

if [[ ! -d node_modules ]]; then
  echo "Installing ChemSite dependencies..."
  npm install
fi

echo "Starting ChemSite at http://localhost:5173"
(sleep 2 && open "http://localhost:5173") &
exec npm start
