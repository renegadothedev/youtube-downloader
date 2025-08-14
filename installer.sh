#!/bin/bash

# Cores para terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verifica se é root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Aviso: Execute este script como root ou com sudo para instalação global${NC}"
    read -p "Continuar como usuário atual? [s/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# Detecta a distribuição Linux
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        DISTRO=$(uname -s)
    fi
}

# Instala dependências básicas
install_dependencies() {
    echo -e "${BLUE}Instalando dependências do sistema...${NC}"
    
    detect_distro
    
    case $DISTRO in
        debian|ubuntu|linuxmint)
            $SUDO apt-get update
            $SUDO apt-get install -y python3 python3-pip python3-venv ffmpeg
            ;;
        fedora|centos|rhel)
            $SUDO dnf install -y python3 python3-pip ffmpeg
            ;;
        arch|manjaro)
            $SUDO pacman -Sy --noconfirm python python-pip ffmpeg
            ;;
        *)
            echo -e "${YELLOW}Distribuição não reconhecida. Instalando apenas Python3 e pip${NC}"
            if command -v apt >/dev/null; then
                $SUDO apt-get install -y python3 python3-pip
            elif command -v dnf >/dev/null; then
                $SUDO dnf install -y python3 python3-pip
            elif command -v yum >/dev/null; then
                $SUDO yum install -y python3 python3-pip
            fi
            ;;
    esac

    # Verifica se o Python foi instalado corretamente
    if ! command -v python3 >/dev/null; then
        echo -e "${RED}Erro: Falha ao instalar Python3${NC}"
        exit 1
    fi
}

# Instala dependências Python
install_python_packages() {
    echo -e "${BLUE}Instalando pacotes Python...${NC}"
    
    # Cria um virtualenv (opcional)
    read -p "Deseja criar um ambiente virtual Python? [S/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        PIP_CMD="pip3"
        PYTHON_CMD="python3"
    else
        echo -e "${GREEN}Criando virtualenv em ./venv${NC}"
        python3 -m venv venv
        PIP_CMD="./venv/bin/pip"
        PYTHON_CMD="./venv/bin/python"
    fi
    
    # Instala pacotes
    $PIP_CMD install --upgrade pip
    $PIP_CMD install pytube requests google-api-python-client
    
    # Pacotes opcionais para desenvolvimento
    read -p "Instalar pacotes para desenvolvimento? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $PIP_CMD install black flake8 pytest
    fi
}

# Verifica instalação
verify_installation() {
    echo -e "${BLUE}Verificando instalação...${NC}"
    
    if $PYTHON_CMD -c "import pytube" &>/dev/null; then
        echo -e "${GREEN}Pytube instalado com sucesso!${NC}"
    else
        echo -e "${RED}Erro: Pytube não foi instalado corretamente${NC}"
        exit 1
    fi
    
    if command -v ffmpeg >/dev/null; then
        echo -e "${GREEN}FFmpeg instalado com sucesso!${NC}"
    else
        echo -e "${YELLOW}Aviso: FFmpeg não está instalado. Algumas funcionalidades podem não funcionar${NC}"
    fi
}

# Main
echo -e "${GREEN}\nYouTube Downloader - Instalador${NC}"
echo -e "${BLUE}===================================${NC}\n"

install_dependencies
install_python_packages
verify_installation

echo -e "\n${GREEN}Instalação concluída com sucesso!${NC}"
echo -e "${YELLOW}Execute o script start.sh para iniciar o Script.${NC}"
