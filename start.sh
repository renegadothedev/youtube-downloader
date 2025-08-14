#!/bin/bash
# Start script with virtualenv support

PY_SCRIPT="src/youtube.py"
VENV_DIR="venv"

# Verifica Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado."
    exit 1
fi

# Ativa virtualenv se existir
if [ -d "$VENV_DIR" ]; then
    echo "🔹 Ativando virtualenv..."
    source "$VENV_DIR/bin/activate"
fi

# Instala pytube se não estiver presente
if ! python3 -c "import pytube" &> /dev/null; then
    echo "⚠ pytube não encontrado. Instalando..."
    pip install pytube
fi

# Executa o script
python3 "$PY_SCRIPT"
EXIT_STATUS=$?

exit $EXIT_STATUS
