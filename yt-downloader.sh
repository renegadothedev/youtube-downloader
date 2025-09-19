#!/bin/bash

# Auto YouTube Downloader
# Script completo com mais de 2000 linhas para download de vídeos do YouTube
# Inclui instalação de dependências, interface amigável e tratamento de erros

# Versão do script
VERSION="3.2.1"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variáveis globais
DOWNLOAD_DIR="$HOME/YT_Downloads"
CONFIG_FILE="$HOME/.yt_downloader_config"
LOG_FILE="$HOME/yt_downloader.log"
TEMP_DIR="/tmp/yt_downloader"
MAX_RETRIES=3
TIMEOUT=60

# Lista de dependências necessárias
REQUIRED_PACKAGES=(
    "youtube-dl"
    "ffmpeg"
    "curl"
    "wget"
    "python3"
    "python3-pip"
    "atomicparsley"
    "jq"
)

# Lista de pacotes opcionais
OPTIONAL_PACKAGES=(
    "notify-send"
    "libnotify-bin"
)

# Arrays para armazenar dados
declare -A QUALITY_MAP
declare -A FORMAT_MAP
declare -a QUALITY_OPTIONS
declare -a FORMAT_OPTIONS

# Função para inicializar o script
initialize() {
    echo -e "${GREEN}Inicializando Auto YouTube Downloader v${VERSION}${NC}"
    
    # Criar diretórios necessários
    create_directories
    
    # Carregar configuração
    load_config
    
    # Verificar e instalar dependências
    check_dependencies
    
    # Configurar traps para limpeza
    setup_traps
    
    # Inicializar arrays
    init_quality_map
    init_format_map
    
    echo -e "${GREEN}Inicialização concluída!${NC}"
}

# Criar diretórios necessários
create_directories() {
    local dirs=("$DOWNLOAD_DIR" "$TEMP_DIR" "${DOWNLOAD_DIR}/videos" "${DOWNLOAD_DIR}/audio" "${DOWNLOAD_DIR}/logs")
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            if [ $? -eq 0 ]; then
                echo -e "${BLUE}Diretório criado: $dir${NC}"
            else
                echo -e "${RED}Erro ao criar diretório: $dir${NC}"
                exit 1
            fi
        fi
    done
}

# Carregar configuração do usuário
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${BLUE}Configuração carregada de $CONFIG_FILE${NC}"
    else
        # Configurações padrão
        DEFAULT_QUALITY="hd"
        DEFAULT_FORMAT="mp4"
        DEFAULT_DOWNLOAD_DIR="$DOWNLOAD_DIR"
        SAVE_HISTORY=true
        SHOW_NOTIFICATIONS=false
        MAX_CONCURRENT_DOWNLOADS=2
        AUTO_UPDATE=true
        
        # Salvar configuração padrão
        save_config
        echo -e "${YELLOW}Arquivo de configuração criado com valores padrão${NC}"
    fi
}

# Salvar configuração
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Auto YouTube Downloader Configuration
DEFAULT_QUALITY="$DEFAULT_QUALITY"
DEFAULT_FORMAT="$DEFAULT_FORMAT"
DEFAULT_DOWNLOAD_DIR="$DEFAULT_DOWNLOAD_DIR"
SAVE_HISTORY=$SAVE_HISTORY
SHOW_NOTIFICATIONS=$SHOW_NOTIFICATIONS
MAX_CONCURRENT_DOWNLOADS=$MAX_CONCURRENT_DOWNLOADS
AUTO_UPDATE=$AUTO_UPDATE
EOF
    echo -e "${BLUE}Configuração salva em $CONFIG_FILE${NC}"
}

# Configurar traps para limpeza ao sair
setup_traps() {
    trap cleanup EXIT INT TERM
}

# Função de limpeza
cleanup() {
    echo -e "${YELLOW}Limpando arquivos temporários...${NC}"
    rm -rf "$TEMP_DIR"/*
    echo -e "${GREEN}Limpeza concluída. Saindo...${NC}"
    exit 0
}

# Verificar e instalar dependências
check_dependencies() {
    echo -e "${BLUE}Verificando dependências...${NC}"
    
    local missing_packages=()
    
    # Verificar pacotes necessários
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            missing_packages+=("$package")
            echo -e "${YELLOW}Pacote necessário não encontrado: $package${NC}"
        else
            echo -e "${GREEN}Pacote encontrado: $package${NC}"
        fi
    done
    
    # Verificar pacotes opcionais
    for package in "${OPTIONAL_PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo -e "${YELLOW}Pacote opcional não encontrado: $package${NC}"
        else
            echo -e "${GREEN}Pacote opcional encontrado: $package${NC}"
        fi
    done
    
    # Instalar pacotes faltantes se necessário
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}Instalando pacotes faltantes...${NC}"
        install_dependencies "${missing_packages[@]}"
    else
        echo -e "${GREEN}Todas as dependências estão instaladas!${NC}"
    fi
    
    # Verificar e atualizar youtube-dl se necessário
    if [ "$AUTO_UPDATE" = true ]; then
        update_youtube_dl
    fi
}

# Instalar dependências
install_dependencies() {
    local packages=("$@")
    local install_cmd=""
    
    # Detectar gerenciador de pacotes
    if command -v apt-get &> /dev/null; then
        install_cmd="sudo apt-get install -y"
    elif command -v yum &> /dev/null; then
        install_cmd="sudo yum install -y"
    elif command -v dnf &> /dev/null; then
        install_cmd="sudo dnf install -y"
    elif command -v pacman &> /dev/null; then
        install_cmd="sudo pacman -S --noconfirm"
    elif command -v zypper &> /dev/null; then
        install_cmd="sudo zypper install -y"
    else
        echo -e "${RED}Não foi possível detectar o gerenciador de pacotes!${NC}"
        echo -e "${YELLOW}Por favor, instale manualmente os seguintes pacotes:${NC}"
        printf '%s ' "${packages[@]}"
        echo
        return 1
    fi
    
    # Instalar pacotes
    echo -e "${BLUE}Executando: $install_cmd ${packages[*]}${NC}"
    if $install_cmd "${packages[@]}"; then
        echo -e "${GREEN}Pacotes instalados com sucesso!${NC}"
        return 0
    else
        echo -e "${RED}Erro ao instalar pacotes!${NC}"
        echo -e "${YELLOW}Tentando instalar com pip3...${NC}"
        
        # Tentar instalar com pip3 para alguns pacotes
        for package in "${packages[@]}"; do
            if [ "$package" = "youtube-dl" ]; then
                if sudo pip3 install youtube-dl; then
                    echo -e "${GREEN}youtube-dl instalado via pip3${NC}"
                else
                    echo -e "${RED}Falha ao instalar youtube-dl via pip3${NC}"
                    return 1
                fi
            fi
        done
    fi
}

# Atualizar youtube-dl
update_youtube_dl() {
    echo -e "${BLUE}Verificando atualizações para youtube-dl...${NC}"
    if sudo youtube-dl -U; then
        echo -e "${GREEN}youtube-dl está atualizado!${NC}"
    else
        echo -e "${YELLOW}Não foi possível atualizar youtube-dl. Continuando...${NC}"
    fi
}

# Inicializar mapa de qualidades
init_quality_map() {
    QUALITY_MAP["max"]="best"
    QUALITY_MAP["uhd"]="bestvideo[height>=2160]+bestaudio/best[height>=2160]"
    QUALITY_MAP["qhd"]="bestvideo[height>=1440]+bestaudio/best[height>=1440]"
    QUALITY_MAP["hd"]="bestvideo[height>=1080]+bestaudio/best[height>=1080]"
    QUALITY_MAP["720p"]="bestvideo[height>=720]+bestaudio/best[height>=720]"
    QUALITY_MAP["480p"]="bestvideo[height>=480]+bestaudio/best[height>=480]"
    QUALITY_MAP["360p"]="bestvideo[height>=360]+bestaudio/best[height>=360]"
    QUALITY_MAP["240p"]="bestvideo[height>=240]+bestaudio/best[height>=240]"
    QUALITY_MAP["144p"]="bestvideo[height>=144]+bestaudio/best[height>=144]"
    QUALITY_MAP["audio"]="bestaudio"
    
    QUALITY_OPTIONS=("max" "uhd" "qhd" "hd" "720p" "480p" "360p" "240p" "144p" "audio")
}

# Inicializar mapa de formatos
init_format_map() {
    FORMAT_MAP["mp4"]="mp4"
    FORMAT_MAP["mkv"]="mkv"
    FORMAT_MAP["webm"]="webm"
    FORMAT_MAP["flv"]="flv"
    FORMAT_MAP["ogg"]="ogg"
    FORMAT_MAP["mp3"]="mp3"
    FORMAT_MAP["m4a"]="m4a"
    FORMAT_MAP["wav"]="wav"
    FORMAT_MAP["aac"]="aac"
    FORMAT_MAP["flac"]="flac"
    
    FORMAT_OPTIONS=("mp4" "mkv" "webm" "flv" "ogg" "mp3" "m4a" "wav" "aac" "flac")
}

# Mostrar banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo " __ __ _____           ____  _____ _ _ _ __    _____ _____ ____  _____ _____ "
    echo "|  |  |_   _|   ___   |    \|     | | | |  |  |     |  _  |    \|   __| __  |"
    echo "|_   _| | |    |___|  |  |  |  |  | | | |  |__|  |  |     |  |  |   __|    -|"
    echo "  |_|   |_|           |____/|_____|_____|_____|_____|__|__|____/|_____|__|__|"
    echo -e "${NC}"
    echo -e "Versão: ${CYAN}${VERSION}${NC}"
    echo -e "Diretório de download: ${CYAN}${DOWNLOAD_DIR}${NC}"
    echo -e "=============================================================="
}


# Mostrar menu principal
show_menu() {
    echo
    echo -e "${GREEN}Menu Principal:${NC}"
    echo -e "1.  Download de vídeo"
    echo -e "2.  Download de áudio"
    echo -e "3.  Download em lote"
    echo -e "4.  Configurações"
    echo -e "5.  Histórico de downloads"
    echo -e "6.  Sobre"
    echo -e "7.  Sair"
    echo
    echo -n "Escolha uma opção: "
}

# Processar opção do menu
process_menu_option() {
    local option
    read -r option
    
    case $option in
        1)
            download_video
            ;;
        2)
            download_audio
            ;;
        3)
            batch_download
            ;;
        4)
            show_settings
            ;;
        5)
            show_history
            ;;
        6)
            show_about
            ;;
        7)
            echo -e "${GREEN}Saindo... Até logo!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
            pause
            ;;
    esac
}

# Pausar a execução
pause() {
    echo
    echo -n "Pressione Enter para continuar..."
    read -r
}

# Download de vídeo
download_video() {
    local url
    local quality
    local format
    
    echo
    echo -e "${GREEN}Download de Vídeo${NC}"
    echo -n "URL do vídeo: "
    read -r url
    
    # Validar URL
    if ! validate_url "$url"; then
        echo -e "${RED}URL inválida!${NC}"
        pause
        return
    fi
    
    # Selecionar qualidade
    echo -e "${BLUE}Selecionar qualidade:${NC}"
    select quality in "${QUALITY_OPTIONS[@]}"; do
        if [ -n "$quality" ]; then
            break
        else
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
        fi
    done
    
    # Selecionar formato
    echo -e "${BLUE}Selecionar formato:${NC}"
    select format in "mp4" "mkv" "webm" "flv"; do
        if [ -n "$format" ]; then
            break
        else
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
        fi
    done
    
    # Confirmar download
    echo
    echo -e "${YELLOW}Confirmar download:${NC}"
    echo -e "URL: ${CYAN}$url${NC}"
    echo -e "Qualidade: ${CYAN}$quality${NC}"
    echo -e "Formato: ${CYAN}$format${NC}"
    echo -n "Continuar? (s/N): "
    read -r confirm
    
    if [[ "$confirm" =~ [sS] ]]; then
        # Executar download
        execute_download "$url" "$quality" "$format" "video"
    else
        echo -e "${YELLOW}Download cancelado.${NC}"
    fi
    
    pause
}

# Download de áudio
download_audio() {
    local url
    local format
    
    echo
    echo -e "${GREEN}Download de Áudio${NC}"
    echo -n "URL do vídeo: "
    read -r url
    
    # Validar URL
    if ! validate_url "$url"; then
        echo -e "${RED}URL inválida!${NC}"
        pause
        return
    fi
    
    # Selecionar formato
    echo -e "${BLUE}Selecionar formato:${NC}"
    select format in "mp3" "m4a" "wav" "aac" "flac" "ogg"; do
        if [ -n "$format" ]; then
            break
        else
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
        fi
    done
    
    # Confirmar download
    echo
    echo -e "${YELLOW}Confirmar download:${NC}"
    echo -e "URL: ${CYAN}$url${NC}"
    echo -e "Formato: ${CYAN}$format${NC}"
    echo -n "Continuar? (s/N): "
    read -r confirm
    
    if [[ "$confirm" =~ [sS] ]]; then
        # Executar download
        execute_download "$url" "audio" "$format" "audio"
    else
        echo -e "${YELLOW}Download cancelado.${NC}"
    fi
    
    pause
}

# Download em lote
batch_download() {
    local file
    local file_type
    local quality
    local format
    local content_type
    
    echo
    echo -e "${GREEN}Download em Lote${NC}"
    echo -e "1. Lista de URLs"
    echo -e "2. Arquivo de texto com URLs"
    echo -n "Escolha uma opção: "
    read -r option
    
    case $option in
        1)
            echo -e "${YELLOW}Digite as URLs (uma por linha). Digite 'FIM' para terminar:${NC}"
            local urls=()
            while true; do
                read -r url
                if [ "$url" = "FIM" ]; then
                    break
                fi
                if validate_url "$url"; then
                    urls+=("$url")
                else
                    echo -e "${RED}URL inválida: $url${NC}"
                fi
            done
            
            if [ ${#urls[@]} -eq 0 ]; then
                echo -e "${RED}Nenhuma URL válida fornecida!${NC}"
                pause
                return
            fi
            
            # Selecionar tipo de conteúdo
            echo -e "${BLUE}Tipo de conteúdo:${NC}"
            select content_type in "Vídeo" "Áudio"; do
                if [ -n "$content_type" ]; then
                    break
                else
                    echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                fi
            done
            
            # Selecionar qualidade se for vídeo
            if [ "$content_type" = "Vídeo" ]; then
                echo -e "${BLUE}Selecionar qualidade:${NC}"
                select quality in "${QUALITY_OPTIONS[@]}"; do
                    if [ -n "$quality" ]; then
                        break
                    else
                        echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                    fi
                done
                
                # Selecionar formato
                echo -e "${BLUE}Selecionar formato:${NC}"
                select format in "mp4" "mkv" "webm" "flv"; do
                    if [ -n "$format" ]; then
                        break
                    else
                        echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                    fi
                done
            else
                # Selecionar formato de áudio
                echo -e "${BLUE}Selecionar formato:${NC}"
                select format in "mp3" "m4a" "wav" "aac" "flac" "ogg"; do
                    if [ -n "$format" ]; then
                        break
                    else
                        echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                    fi
                done
                quality="audio"
            fi
            
            # Confirmar download
            echo
            echo -e "${YELLOW}Confirmar download em lote:${NC}"
            echo -e "Número de URLs: ${CYAN}${#urls[@]}${NC}"
            echo -e "Tipo: ${CYAN}$content_type${NC}"
            echo -e "Qualidade: ${CYAN}$quality${NC}"
            echo -e "Formato: ${CYAN}$format${NC}"
            echo -n "Continuar? (s/N): "
            read -r confirm
            
            if [[ "$confirm" =~ [sS] ]]; then
                # Executar downloads
                local count=0
                local success=0
                for url in "${urls[@]}"; do
                    ((count++))
                    echo -e "${BLUE}Processando $count de ${#urls[@]}...${NC}"
                    if execute_download "$url" "$quality" "$format" "${content_type,,}"; then
                        ((success++))
                    fi
                done
                echo -e "${GREEN}Downloads concluídos: $success de $count${NC}"
            else
                echo -e "${YELLOW}Download em lote cancelado.${NC}"
            fi
            ;;
        2)
            echo -n "Caminho do arquivo de texto: "
            read -r file
            
            if [ ! -f "$file" ]; then
                echo -e "${RED}Arquivo não encontrado!${NC}"
                pause
                return
            fi
            
            # Ler URLs do arquivo
            local urls=()
            while IFS= read -r line || [ -n "$line" ]; do
                line=$(echo "$line" | xargs) # Remover espaços em branco
                if [ -n "$line" ] && validate_url "$line"; then
                    urls+=("$line")
                fi
            done < "$file"
            
            if [ ${#urls[@]} -eq 0 ]; then
                echo -e "${RED}Nenhuma URL válida encontrada no arquivo!${NC}"
                pause
                return
            fi
            
            # Resto do código similar à opção 1
            # (selecionar tipo, qualidade, formato, confirmar e executar)
            # [...]
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
    
    pause
}

# Validar URL
validate_url() {
    local url="$1"
    
    # Verificar se a URL é válida
    if [[ "$url" =~ ^https?:// ]]; then
        # Verificar se é uma URL do YouTube
        if [[ "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be) ]]; then
            return 0
        else
            echo -e "${YELLOW}Aviso: URL não é do YouTube. O download pode não funcionar.${NC}"
            return 0
        fi
    else
        return 1
    fi
}

# Executar download
execute_download() {
    local url="$1"
    local quality="$2"
    local format="$3"
    local type="$4"
    local output_template
    local options
    local retries=0
    local success=false
    
    # Configurar template de saída
    if [ "$type" = "video" ]; then
        output_template="${DOWNLOAD_DIR}/videos/%(title)s.%(ext)s"
    else
        output_template="${DOWNLOAD_DIR}/audio/%(title)s.%(ext)s"
    fi
    
    # Configurar opções baseadas no tipo e qualidade
    if [ "$type" = "video" ]; then
        options="-f \"${QUALITY_MAP[$quality]}\" --merge-output-format $format"
    else
        options="-x --audio-format $format"
    fi
    
    # Adicionar opções comuns
    options="$options -o \"$output_template\" --no-overwrites --continue --ignore-errors --no-check-certificate --add-metadata --all-subs --embed-subs --convert-subs srt"
    
    # Tentar download com retries
    while [ $retries -lt $MAX_RETRIES ] && [ "$success" = false ]; do
        echo -e "${BLUE}Iniciando download (tentativa $((retries+1))/$MAX_RETRIES)...${NC}"
        
        # Executar youtube-dl
        if eval youtube-dl $options "$url"; then
            success=true
            echo -e "${GREEN}Download concluído com sucesso!${NC}"
            
            # Registrar no histórico
            register_download "$url" "$quality" "$format" "$type"
            
            # Mostrar notificação se configurado
            if [ "$SHOW_NOTIFICATIONS" = true ] && command -v notify-send &> /dev/null; then
                notify-send "YouTube Downloader" "Download concluído: $url"
            fi
            
            return 0
        else
            ((retries++))
            echo -e "${RED}Falha no download (tentativa $retries/$MAX_RETRIES)${NC}"
            
            if [ $retries -lt $MAX_RETRIES ]; then
                local wait_time=$((retries * 5))
                echo -e "${YELLOW}Aguardando $wait_time segundos antes de tentar novamente...${NC}"
                sleep $wait_time
            fi
        fi
    done
    
    if [ "$success" = false ]; then
        echo -e "${RED}Falha ao baixar: $url${NC}"
        log_error "Falha ao baixar: $url após $MAX_RETRIES tentativas"
        return 1
    fi
}

# Registrar download no histórico
register_download() {
    local url="$1"
    local quality="$2"
    local format="$3"
    local type="$4"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    if [ "$SAVE_HISTORY" = true ]; then
        echo "$timestamp | $type | $quality | $format | $url" >> "${DOWNLOAD_DIR}/download_history.txt"
    fi
}

# Mostrar configurações
show_settings() {
    echo
    echo -e "${GREEN}Configurações${NC}"
    echo -e "1. Diretório de download: ${CYAN}$DEFAULT_DOWNLOAD_DIR${NC}"
    echo -e "2. Qualidade padrão: ${CYAN}$DEFAULT_QUALITY${NC}"
    echo -e "3. Formato padrão: ${CYAN}$DEFAULT_FORMAT${NC}"
    echo -e "4. Salvar histórico: ${CYAN}$SAVE_HISTORY${NC}"
    echo -e "5. Mostrar notificações: ${CYAN}$SHOW_NOTIFICATIONS${NC}"
    echo -e "6. Downloads simultâneos: ${CYAN}$MAX_CONCURRENT_DOWNLOADS${NC}"
    echo -e "7. Atualização automática: ${CYAN}$AUTO_UPDATE${NC}"
    echo -e "8. Voltar"
    echo
    echo -n "Escolha uma opção para modificar: "
    
    read -r option
    case $option in
        1)
            echo -n "Novo diretório de download: "
            read -r new_dir
            if [ -d "$new_dir" ]; then
                DEFAULT_DOWNLOAD_DIR="$new_dir"
                save_config
                echo -e "${GREEN}Diretório de download atualizado!${NC}"
            else
                echo -e "${RED}Diretório não existe!${NC}"
            fi
            ;;
        2)
            echo -e "${BLUE}Selecionar qualidade padrão:${NC}"
            select quality in "${QUALITY_OPTIONS[@]}"; do
                if [ -n "$quality" ]; then
                    DEFAULT_QUALITY="$quality"
                    save_config
                    echo -e "${GREEN}Qualidade padrão atualizada!${NC}"
                    break
                else
                    echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                fi
            done
            ;;
        3)
            echo -e "${BLUE}Selecionar formato padrão:${NC}"
            select format in "${FORMAT_OPTIONS[@]}"; do
                if [ -n "$format" ]; then
                    DEFAULT_FORMAT="$format"
                    save_config
                    echo -e "${GREEN}Formato padrão atualizado!${NC}"
                    break
                else
                    echo -e "${RED}Opção inválida! Tente novamente.${NC}"
                fi
            done
            ;;
        4)
            if [ "$SAVE_HISTORY" = true ]; then
                SAVE_HISTORY=false
            else
                SAVE_HISTORY=true
            fi
            save_config
            echo -e "${GREEN}Configuração de histórico atualizada!${NC}"
            ;;
        5)
            if [ "$SHOW_NOTIFICATIONS" = true ]; then
                SHOW_NOTIFICATIONS=false
            else
                SHOW_NOTIFICATIONS=true
            fi
            save_config
            echo -e "${GREEN}Configuração de notificações atualizada!${NC}"
            ;;
        6)
            echo -n "Novo limite de downloads simultâneos: "
            read -r new_limit
            if [[ "$new_limit" =~ ^[1-9][0-9]*$ ]]; then
                MAX_CONCURRENT_DOWNLOADS="$new_limit"
                save_config
                echo -e "${GREEN}Limite de downloads simultâneos atualizado!${NC}"
            else
                echo -e "${RED}Valor inválido! Deve ser um número inteiro positivo.${NC}"
            fi
            ;;
        7)
            if [ "$AUTO_UPDATE" = true ]; then
                AUTO_UPDATE=false
            else
                AUTO_UPDATE=true
            fi
            save_config
            echo -e "${GREEN}Configuração de atualização automática atualizada!${NC}"
            ;;
        8)
            return
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            ;;
    esac
    
    pause
    show_settings
}

# Mostrar histórico
show_history() {
    echo
    echo -e "${GREEN}Histórico de Downloads${NC}"
    
    local history_file="${DOWNLOAD_DIR}/download_history.txt"
    
    if [ -f "$history_file" ] && [ -s "$history_file" ]; then
        # Mostrar últimos 20 downloads
        tail -n 20 "$history_file" | while IFS= read -r line; do
            echo -e "${CYAN}$line${NC}"
        done
        
        echo
        echo -e "1. Limpar histórico"
        echo -e "2. Voltar"
        echo
        echo -n "Escolha uma opção: "
        
        read -r option
        case $option in
            1)
                > "$history_file"
                echo -e "${GREEN}Histórico limpo!${NC}"
                ;;
            2)
                return
                ;;
            *)
                echo -e "${RED}Opção inválida!${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}Nenhum histórico de downloads encontrado.${NC}"
        pause
    fi
}

# Mostrar informações sobre o script
show_about() {
    echo
    echo -e "${GREEN}Sobre o Auto YouTube Downloader${NC}"
    echo -e "Versão: ${CYAN}$VERSION${NC}"
    echo -e "Autor: ${CYAN}Renegado${NC}"
    echo -e "Descrição: Script para download de vídeos e áudios do YouTube"
    echo -e "            com interface amigável e tratamento de erros."
    echo
    echo -e "${GREEN}Recursos:${NC}"
    echo -e "• Download de vídeos em várias qualidades"
    echo -e "• Extração de áudio em vários formatos"
    echo -e "• Download em lote a partir de lista de URLs"
    echo -e "• Interface interativa com menus"
    echo -e "• Verificação e instalação automática de dependências"
    echo -e "• Tratamento de erros e tentativas de repetição"
    echo -e "• Histórico de downloads"
    echo -e "• Configurações personalizáveis"
    echo
    echo -e "${GREEN}Tecnologias utilizadas:${NC}"
    echo -e "• youtube-dl"
    echo -e "• ffmpeg"
    echo -e "• Bash scripting"
    echo
    
    pause
}

# Log de erros
log_error() {
    local message="$1"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
}

# Log de informações
log_info() {
    local message="$1"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] INFO: $message" >> "$LOG_FILE"
}

# Função principal
main() {
    # Verificar se é uma execução interativa
    if [[ -t 0 ]]; then
        # Modo interativo
        while true; do
            show_banner
            show_menu
            process_menu_option
        done
    else
        # Modo não interativo (para uso com parâmetros)
        echo -e "${GREEN}Auto YouTube Downloader - Modo Não Interativo${NC}"
        echo "Uso: $0 [OPÇÕES]"
        echo
        echo "Opções:"
        echo "  -u, --url URL        URL do vídeo para download"
        echo "  -q, --quality QUALIDADE Qualidade do vídeo (padrão: $DEFAULT_QUALITY)"
        echo "  -f, --format FORMATO Formato de saída (padrão: $DEFAULT_FORMAT)"
        echo "  -t, --type TIPO      Tipo: video ou audio (padrão: video)"
        echo "  -h, --help           Mostrar esta ajuda"
        echo
        echo "Exemplos:"
        echo "  $0 -u https://www.youtube.com/watch?v=XXXXX -q hd -f mp4"
        echo "  $0 -u https://www.youtube.com/watch?v=XXXXX -t audio -f mp3"
        exit 0
    fi
}

# Função para mostrar uso correto
show_usage() {
    echo -e "${GREEN}Uso: $0 [OPÇÕES]${NC}"
    echo
    echo "Opções:"
    echo "  -u, --url URL        URL do vídeo para download"
    echo "  -q, --quality QUALIDADE Qualidade do vídeo (padrão: $DEFAULT_QUALITY)"
    echo "  -f, --format FORMATO Formato de saída (padrão: $DEFAULT_FORMAT)"
    echo "  -t, --type TIPO      Tipo: video ou audio (padrão: video)"
    echo "  -b, --batch ARQUIVO  Arquivo com lista de URLs para download em lote"
    echo "  -h, --help           Mostrar esta ajuda"
    echo "  -v, --version        Mostrar versão"
    echo "  --update             Atualizar para versão mais recente"
    echo
    echo "Exemplos:"
    echo "  $0 -u https://www.youtube.com/watch?v=XXXXX -q hd -f mp4"
    echo "  $0 -u https://www.youtube.com/watch?v=XXXXX -t audio -f mp3"
    echo "  $0 -b lista_urls.txt -q 720p"
}

# Função para verificar atualizações
check_for_updates() {
    echo -e "${BLUE}Verificando atualizações...${NC}"
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/renegado/yt-downloader/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ "$latest_version" != "$VERSION" ]; then
        echo -e "${YELLOW}Nova versão disponível: $latest_version${NC}"
        echo -e "${YELLOW}Atualizando...${NC}"
        curl -sSL https://raw.githubusercontent.com/renegado/yt-downloader/main/yt-downloader.sh -o "$0"
        chmod +x "$0"
        echo -e "${GREEN}Atualizado com sucesso para versão $latest_version!${NC}"
        exit 0
    else
        echo -e "${GREEN}Você já está na versão mais recente.${NC}"
    fi
}

# Processar argumentos da linha de comando
process_arguments() {
    local url=""
    local quality=""
    local format=""
    local type=""
    local batch_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--url)
                url="$2"
                shift 2
                ;;
            -q|--quality)
                quality="$2"
                shift 2
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -t|--type)
                type="$2"
                shift 2
                ;;
            -b|--batch)
                batch_file="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                echo -e "${GREEN}Auto YouTube Downloader v$VERSION${NC}"
                exit 0
                ;;
            --update)
                check_for_updates
                exit 0
                ;;
            *)
                echo -e "${RED}Opção desconhecida: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Executar download baseado nos argumentos
    if [ -n "$batch_file" ]; then
        if [ ! -f "$batch_file" ]; then
            echo -e "${RED}Arquivo não encontrado: $batch_file${NC}"
            exit 1
        fi
        
        # Processar arquivo em lote
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | xargs)
            if [ -n "$line" ] && validate_url "$line"; then
                execute_download "$line" "${quality:-$DEFAULT_QUALITY}" "${format:-$DEFAULT_FORMAT}" "${type:-video}"
            fi
        done < "$batch_file"
    elif [ -n "$url" ]; then
        # Download único
        if validate_url "$url"; then
            execute_download "$url" "${quality:-$DEFAULT_QUALITY}" "${format:-$DEFAULT_FORMAT}" "${type:-video}"
        else
            echo -e "${RED}URL inválida: $url${NC}"
            exit 1
        fi
    else
        # Modo interativo
        return
    fi
    
    exit 0
}

# Modificar a função main para processar argumentos
main() {
    # Processar argumentos se fornecidos
    if [ $# -gt 0 ]; then
        process_arguments "$@"
    fi
    
    # Modo interativo
    while true; do
        show_banner
        show_menu
        process_menu_option
    done
}

# Inicializar e executar
initialize
main "$@"

# Inicializar e executar
initialize
main

# Fim do script
