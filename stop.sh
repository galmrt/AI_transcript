#!/bin/bash

# 🛑 Stop All Transcript App Services

echo "🛑 Stopping Transcript App..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Stop Frontend (React/Vite - check multiple ports)
echo -e "${YELLOW}1. Stopping Frontend...${NC}"
STOPPED=0
for PORT in 5173 5174 5175 3000; do
    FRONTEND_PID=$(lsof -ti:$PORT 2>/dev/null)
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        echo -e "${GREEN}   ✅ Frontend stopped (port $PORT)${NC}"
        STOPPED=1
    fi
done
if [ $STOPPED -eq 0 ]; then
    echo -e "${YELLOW}   ⚠️  Frontend not running${NC}"
fi

# Stop Backend (FastAPI on port 8000)
echo -e "${YELLOW}2. Stopping Backend...${NC}"
BACKEND_PID=$(lsof -ti:8000)
if [ ! -z "$BACKEND_PID" ]; then
    kill $BACKEND_PID 2>/dev/null
    echo -e "${GREEN}   ✅ Backend stopped${NC}"
else
    echo -e "${YELLOW}   ⚠️  Backend not running${NC}"
fi

# Stop Elasticsearch (Docker)
echo -e "${YELLOW}3. Stopping Elasticsearch...${NC}"
cd backend
docker-compose down > /dev/null 2>&1
cd ..
echo -e "${GREEN}   ✅ Elasticsearch stopped${NC}"

# Optional: Stop Ollama (only if we started it)
# Uncomment if you want to stop Ollama too
# echo -e "${YELLOW}4. Stopping Ollama...${NC}"
# pkill -f "ollama serve" 2>/dev/null
# echo -e "${GREEN}   ✅ Ollama stopped${NC}"

echo ""
echo -e "${GREEN}✅ All services stopped!${NC}"
echo ""

