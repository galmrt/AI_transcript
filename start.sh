#!/bin/bash

# 🚀 Transcript App Startup Script
# This script starts all services needed for the app

set -e

echo "🚀 Starting Transcript App..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if Ollama is running
if ! curl -s http://localhost:11434/v1/models > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Ollama is not running.${NC}"
    echo "   Please start Ollama in another terminal: ollama serve"
    echo "   Or install it: https://ollama.ai"
    echo ""
    read -p "Press Enter when Ollama is running, or Ctrl+C to exit..."
fi

# Start Elasticsearch
echo -e "${GREEN}1. Starting Elasticsearch...${NC}"
cd backend
docker-compose up -d
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

echo ""
echo -e "${GREEN}✅ All services started!${NC}"
echo ""
echo "📋 Next steps:"
echo ""
echo "   Terminal 1 (Backend):"
echo "   $ cd backend"
echo "   $ source venv/bin/activate"
echo "   $ uvicorn app:app --reload"
echo ""
echo "   Terminal 2 (Frontend):"
echo "   $ cd frontend"
echo "   $ npm run dev"
echo ""
echo "   Then open: http://localhost:5173"
echo ""
echo "🛑 To stop Elasticsearch:"
echo "   $ cd backend && docker-compose down"
echo ""

