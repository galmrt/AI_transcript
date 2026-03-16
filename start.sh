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

# Check if venv exists
if [ ! -d "venv" ]; then
    echo -e "${RED}❌ Virtual environment not found!${NC}"
    echo ""
    echo "Please run the setup first:"
    echo ""
    echo "  python3 -m venv venv"
    echo "  source venv/bin/activate"
    echo "  pip install -r backend/requirements.txt"
    echo ""
    exit 1
fi

# Check if node_modules exists
if [ ! -d "frontend/node_modules" ]; then
    echo -e "${RED}❌ Frontend dependencies not installed!${NC}"
    echo ""
    echo "Please run the setup first:"
    echo ""
    echo "  cd frontend"
    echo "  npm install"
    echo ""
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if Ollama is running, if not start it
echo -e "${BLUE}0. Checking Ollama...${NC}"
if ! curl -s http://localhost:11434/v1/models > /dev/null 2>&1; then
    echo -e "${YELLOW}   Ollama is not running. Starting Ollama...${NC}"
    ollama serve > ollama.log 2>&1 &
    OLLAMA_PID=$!
    echo -e "${GREEN}   ✅ Ollama started (PID: $OLLAMA_PID)${NC}"

    # Wait for Ollama to be ready
    echo -e "${YELLOW}   Waiting for Ollama to be ready...${NC}"
    for i in {1..15}; do
        if curl -s http://localhost:11434/v1/models > /dev/null 2>&1; then
            echo -e "${GREEN}   ✅ Ollama is ready!${NC}"
            break
        fi
        if [ $i -eq 15 ]; then
            echo -e "${RED}   ❌ Ollama failed to start${NC}"
            exit 1
        fi
        sleep 1
    done
else
    echo -e "${GREEN}   ✅ Ollama is already running${NC}"
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
# Use the venv's python directly instead of activating
../venv/bin/python -m uvicorn app:app --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo -e "${GREEN}   ✅ Backend started (PID: $BACKEND_PID)${NC}"
echo -e "${YELLOW}   Logs: backend.log${NC}"

# Wait for backend to be ready
echo -e "${YELLOW}   Waiting for backend to be ready...${NC}"
for i in {1..15}; do
    if curl -s http://localhost:8000/docs > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Backend is ready!${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}   ❌ Backend failed to start. Check backend.log${NC}"
        tail -20 backend.log
        exit 1
    fi
    sleep 1
done

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
FRONTEND_PORT=""
for i in {1..20}; do
    # Check common Vite ports
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        FRONTEND_PORT="5173"
        echo -e "${GREEN}   ✅ Frontend is ready on port $FRONTEND_PORT!${NC}"
        break
    elif curl -s http://localhost:5174 > /dev/null 2>&1; then
        FRONTEND_PORT="5174"
        echo -e "${GREEN}   ✅ Frontend is ready on port $FRONTEND_PORT!${NC}"
        break
    elif curl -s http://localhost:5175 > /dev/null 2>&1; then
        FRONTEND_PORT="5175"
        echo -e "${GREEN}   ✅ Frontend is ready on port $FRONTEND_PORT!${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}   ❌ Frontend failed to start. Check frontend.log${NC}"
        tail -20 frontend.log
        exit 1
    fi
    sleep 1
done

echo ""
echo -e "${GREEN}✅ All services started successfully!${NC}"
echo ""
echo "📋 Services:"
echo -e "   ${BLUE}Frontend:${NC}      http://localhost:5173  ${GREEN}✓${NC}"
echo -e "   ${BLUE}Backend API:${NC}   http://localhost:8000  ${GREEN}✓${NC}"
echo -e "   ${BLUE}API Docs:${NC}      http://localhost:8000/docs  ${GREEN}✓${NC}"
echo -e "   ${BLUE}Elasticsearch:${NC} http://localhost:9200  ${GREEN}✓${NC}"
echo ""
echo "📊 Process IDs:"
echo "   Backend:  $BACKEND_PID"
echo "   Frontend: $FRONTEND_PID"
echo ""
echo "📝 View Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 To stop all services:"
echo "   ./stop.sh"
echo ""
echo -e "${YELLOW}Opening frontend in browser...${NC}"
sleep 2
open http://localhost:5173 2>/dev/null || echo "Please open http://localhost:5173 in your browser"
echo ""

