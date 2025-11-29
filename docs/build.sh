#!/bin/bash
set -e

echo "🔨 Building API documentation..."
cd "$(dirname "$0")"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Build
npm run build

echo ""
echo "✅ Build complete!"
echo ""
echo "Next steps:"
echo "  1. Preview locally: npm run dev"
echo "  2. Deploy to Cloudflare: npm run deploy"
echo ""
