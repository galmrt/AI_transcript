#!/bin/bash

# 🚀 Transcript App Startup Script
# This script starts ALL services in the background

set -e

echo "🚀 Starting Transcript App..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if Ollama is running, if not start it
if ! curl -s http://localhost:11434/v1/models > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Ollama is not running. Starting Ollama...${NC}"
    ollama serve > /dev/null 2>&1 &
    OLLAMA_PID=$!
    echo -e "${GREEN}   ✅ Ollama started (PID: $OLLAMA_PID)${NC}"
    sleep 2
fi

# Start Elasticsearch
echo -e "${BLUE}1. Starting Elasticsearch...${NC}"
cd backend
docker-compose up -d > /dev/null 2>&1
cd ..

# Wait for Elasticsearch to be ready
echo -e "${YELLOW}   Waiting for Elasticsearch to be ready...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Elasticsearch is ready!${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}   ❌ Elasticsearch failed to start${NC}"
        exit 1
    fi
    sleep 1
done

# Start Backend
echo -e "${BLUE}2. Starting Backend (FastAPI)...${NC}"
cd backend
source venv/bin/activate
uvicorn app:app --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo -e "${GREEN}   ✅ Backend started (PID: $BACKEND_PID)${NC}"
echo -e "${YELLOW}   Logs: backend.log${NC}"

# Wait a bit for backend to start
sleep 3

# Start Frontend
echo -e "${BLUE}3. Starting Frontend (React)...${NC}"
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo -e "${GREEN}   ✅ Frontend started (PID: $FRONTEND_PID)${NC}"
echo -e "${YELLOW}   Logs: frontend.log${NC}"

# Wait for frontend to be ready
echo -e "${YELLOW}   Waiting for frontend to be ready...${NC}"
sleep 5

echo ""
echo -e "${GREEN}✅ All services started successfully!${NC}"
echo ""
echo "📋 Services:"
echo -e "   ${BLUE}Frontend:${NC}      http://localhost:5173"
echo -e "   ${BLUE}Backend API:${NC}   http://localhost:8000"
echo -e "   ${BLUE}API Docs:${NC}      http://localhost:8000/docs"
echo -e "   ${BLUE}Elasticsearch:${NC} http://localhost:9200"
echo ""
echo "📊 Process IDs:"
echo "   Backend:  $BACKEND_PID"
echo "   Frontend: $FRONTEND_PID"
echo ""
echo "📝 Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 To stop all services:"
echo "   ./stop.sh"
echo ""

