#!/usr/bin/env bash
#
# Fails if Bitcoin unit labels (BTC / sats / sat/vB) appear in code paths this
# fork renders. Scope is display text only: identifiers and wire values (the
# 'btc'|'sats'|'fiat' mode union, ?sats= query params, SatsComponent) keep
# Bitcoin's spelling.
set -euo pipefail
cd "$(dirname "$0")"

# Disabled features, wire formats, upstream data files, and unrouted pages.
# Filtered from output rather than via grep --exclude, which silently stopped
# excluding under some shells.
SKIP_PATHS='src/app/lightning/|liquid-reserves-audit|lbtc-pegs-graph|/acceleration|accelerate-checkout|bitcoin-invoice|price-chart|api-docs-data\.ts|websocket\.interface\.ts'
SKIP_PATHS="$SKIP_PATHS"'|components/about/|components/terms-of-service/|components/privacy-policy/|components/trademark-policy/'

# Pre-fork halvings happened on Bitcoin, so those four labels keep BTC.
SKIP_CONTENT='LBTC|halved to (25|12\.5|6\.25|3\.125) BTC per block'

PATTERNS=(
  '\bBTC\b'
  '>sats<'
  '\(sats\)'
  "' sats'"
  '} sats`'
  'sats/WU'
  'sats/vByte'
  'sat/vB\b'
  'sat/WU'
  'sat/vByte'
)

status=0
for p in "${PATTERNS[@]}"; do
  # The description half of i18n="meaning|description" is not rendered, so
  # strip i18n metadata before re-asserting the match.
  hits=$(grep -rnE --include='*.ts' --include='*.html' -- "$p" src/app \
    | grep -vE "$SKIP_PATHS" \
    | grep -vE "$SKIP_CONTENT" \
    | sed 's/ i18n[^=]*="[^"]*"//g' \
    | grep -E -- "$p" || true)
  if [ -n "$hits" ]; then
    echo "Bitcoin unit label found: /$p/"
    echo "$hits" | sed 's/^/  /'
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo
  echo "Rename to the ECX equivalent (ECX / szats / szat/vB), or add a"
  echo "justified exclusion above if it is an identifier or wire value."
  exit 1
fi

echo "no Bitcoin unit labels in rendered code paths"
