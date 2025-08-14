#!/bin/bash

# YouTube Downloader - Launcher
# Versão: 3.0
# Autor: Seu Nome

# Configurações
APP_NAME="YouTube Downloader"
APP_DIR=$(dirname "$(realpath "$0")")
LOG_DIR="${APP_DIR}/src/logs"
PY_SCRIPT="${APP_DIR}/src/youtube.py"
VENV_DIR="${APP_DIR}/venv"
CONFIG_FILE="${APP_DIR}/config.ini"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/youtube_$(date +%Y%m%d_%H%M%S).log"

# Função para mostrar ajuda
show_help() {
    echo -e "${CYAN}Uso: ${0} [OPÇÕES]${NC}"
    echo -e "Opções:"
    echo -e "  -h, --help      Mostra esta ajuda"
    echo -e "  -v, --verbose   Modo verboso"
    echo -e "  -d, --debug     Modo debug (mostra saída completa)"
    echo -e "  -q, --quiet     Modo silencioso"
    echo -e "  --venv          Usar virtualenv (se existir)"
    echo -e "  --no-venv       Não usar virtualenv"
    echo -e "  --log           Salvar log em arquivo"
    echo -e "  --gui           Tentar iniciar interface gráfica (se disponível)"
    echo -e "\nExemplos:"
    echo -e "  ${0} --verbose --log"
    echo -e "  ${0} -q"
}

# Função para verificar dependências
check_dependencies() {
    local missing=0
    
    echo -e "${BLUE}Verificando dependências...${NC}"
    
    # Verifica Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ Python3 não está instalado${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Python3 encontrado${NC}"
        echo -e "  Versão: $(python3 --version | cut -d' ' -f2)"
    fi
    
    # Verifica FFmpeg (opcional mas recomendado)
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${YELLOW}⚠ FFmpeg não encontrado (algumas funcionalidades podem não funcionar)${NC}"
    else
        echo -e "${GREEN}✓ FFmpeg encontrado${NC}"
    fi
    
    # Verifica pacotes Python
    if [[ $USE_VENV -eq 1 && -d "$VENV_DIR" ]]; then
        PY_CMD="${VENV_DIR}/bin/python3"
    else
        PY_CMD="python3"
    fi
    
    if ! $PY_CMD -c "import pytube" &> /dev/null; then
        echo -e "${RED}✗ Pacote 'pytube' não instalado${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Pacote 'pytube' encontrado${NC}"
    fi
    
    return $missing
}

# Função para configurar virtualenv
setup_venv() {
    if [[ $USE_VENV -eq 1 && -d "$VENV_DIR" ]]; then
        echo -e "${BLUE}Ativando virtualenv...${NC}"
        source "${VENV_DIR}/bin/activate"
        echo -e "${GREEN}Virtualenv ativado${NC}"
        return 0
    fi
    return 1
}

# Função principal
main() {
    # Parse arguments
    VERBOSE=0
    DEBUG=0
    QUIET=0
    USE_VENV=0
    LOGGING=0
    GUI_MODE=0
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -d|--debug)
                DEBUG=1
                VERBOSE=1
                shift
                ;;
            -q|--quiet)
                QUIET=1
                shift
                ;;
            --venv)
                USE_VENV=1
                shift
                ;;
            --no-venv)
                USE_VENV=0
                shift
                ;;
            --log)
                LOGGING=1
                shift
                ;;
            --gui)
                GUI_MODE=1
                shift
                ;;
            *)
                echo -e "${RED}Opção desconhecida: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done

    # Banner
    if [[ $QUIET -eq 0 ]]; then
        echo -e "${CYAN}"
        echo "=============================================="
        echo "  $APP_NAME - Launcher"
        echo "  Diretório: $APP_DIR"
        echo "  Horário: $(date)"
        echo "=============================================="
        echo -e "${NC}"
    fi

    # Verificar dependências
    if ! check_dependencies; then
        echo -e "${RED}Erro: Dependências faltando. Execute o installer.sh primeiro.${NC}"
        exit 1
    fi

    # Configurar virtualenv
    if [[ $USE_VENV -eq 1 ]]; then
        if ! setup_venv; then
            echo -e "${YELLOW}Aviso: Virtualenv não encontrado em $VENV_DIR${NC}"
        fi
    fi

    # Comando para executar
    PY_CMD="python3"
    if [[ $USE_VENV -eq 1 && -d "$VENV_DIR" ]]; then
        PY_CMD="${VENV_DIR}/bin/python3"
    fi

    # Opções adicionais
    PY_OPTIONS=""
    if [[ $GUI_MODE -eq 1 ]]; then
        PY_OPTIONS+=" --gui"
    fi

    # Executar o script
    if [[ $QUIET -eq 1 ]]; then
        # Modo silencioso
        $PY_CMD "$PY_SCRIPT" $PY_OPTIONS >/dev/null 2>&1
    elif [[ $LOGGING -eq 1 ]]; then
        # Com logging
        echo -e "${BLUE}Iniciando $APP_NAME (log: $LOG_FILE)...${NC}"
        $PY_CMD "$PY_SCRIPT" $PY_OPTIONS 2>&1 | tee "$LOG_FILE"
    elif [[ $DEBUG -eq 1 ]]; then
        # Modo debug
        echo -e "${YELLOW}Iniciando em modo debug...${NC}"
        $PY_CMD -v "$PY_SCRIPT" $PY_OPTIONS
    elif [[ $VERBOSE -eq 1 ]]; then
        # Modo verboso
        $PY_CMD "$PY_SCRIPT" $PY_OPTIONS
    else
        # Modo normal
        $PY_CMD "$PY_SCRIPT" $PY_OPTIONS
    fi

    # Status de saída
    EXIT_STATUS=$?
    if [[ $EXIT_STATUS -ne 0 && $QUIET -eq 0 ]]; then
        echo -e "${RED}O programa terminou com erro (status: $EXIT_STATUS)${NC}"
    elif [[ $QUIET -eq 0 ]]; then
        echo -e "${GREEN}Execução concluída com sucesso${NC}"
    fi
    exit $EXIT_STATUS
}

# Iniciar
main "$@"