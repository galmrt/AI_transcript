#!/bin/bash

# 📝 View Transcript App Logs

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📝 Transcript App Logs${NC}"
echo ""
echo "Press Ctrl+C to exit"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Follow both logs with labels
tail -f backend.log frontend.log | awk '
/^==> backend.log <==$/ {
    print "\033[0;34m[BACKEND]\033[0m"
    next
}
/^==> frontend.log <==$/ {
    print "\033[0;32m[FRONTEND]\033[0m"
    next
}
/^$/ {
    next
}
{
    print
}
'

