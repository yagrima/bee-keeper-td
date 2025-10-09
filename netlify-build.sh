#!/bin/bash

# ==============================================================================
# NETLIFY BUILD SCRIPT
# ==============================================================================
# This script injects environment variables into the web build at deploy time
# Run automatically by Netlify before publishing

echo "🔧 Netlify Build: Injecting environment variables..."

# Check if index.html exists
if [ ! -f "builds/web/index.html" ]; then
    echo "❌ ERROR: builds/web/index.html not found!"
    echo "Please run Godot web export first!"
    exit 1
fi

# Backup original
cp builds/web/index.html builds/web/index.html.backup

# Replace %PLACEHOLDERS% with actual Netlify environment variables
# The index.html already contains window.BKTD_ENV with placeholders like %SUPABASE_URL%

echo "Replacing %SUPABASE_URL% with ${SUPABASE_URL}"
sed -i "s|%SUPABASE_URL%|${SUPABASE_URL}|g" builds/web/index.html

echo "Replacing %SUPABASE_ANON_KEY% with ${SUPABASE_ANON_KEY}"
sed -i "s|%SUPABASE_ANON_KEY%|${SUPABASE_ANON_KEY}|g" builds/web/index.html

echo "Replacing %BKTD_HMAC_SECRET% with ${BKTD_HMAC_SECRET}"
sed -i "s|%BKTD_HMAC_SECRET%|${BKTD_HMAC_SECRET}|g" builds/web/index.html

echo "✅ Environment variables injected successfully"
echo "🚀 Build ready for deployment"

# Verify the injection
if grep -q "window.BKTD_ENV" builds/web/index.html; then
    echo "✅ Verification: window.BKTD_ENV found in index.html"
else
    echo "⚠️ WARNING: window.BKTD_ENV not found! Injection may have failed."
fi
