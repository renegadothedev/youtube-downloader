#!/usr/bin/env python3
"""
YouTube Downloader - Ferramenta para baixar vídeos do YouTube
"""
from pytube import YouTube
from pytube.exceptions import PytubeError
import os
import sys
from typing import Optional

# Configuração de cores para o terminal (ANSI escape codes)
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    END = '\033[0m'
    BOLD = '\033[1m'

# Constantes
VIDEOS_DIR = os.path.join("src", "videos")
SUPPORTED_QUALITIES = ["highest", "lowest", "audio"]

def setup_environment() -> None:
    """Cria a estrutura de diretórios necessária"""
    os.makedirs(VIDEOS_DIR, exist_ok=True)

def display_banner() -> None:
    """Exibe o banner estilizado do programa"""
    banner = f"""
    {Colors.BOLD}{Colors.BLUE}
    ####################################
    #                                  #
    #       YouTube Downloader         #
    #                                  #
    ####################################
    {Colors.END}
    """
    print(banner)

def get_user_input() -> tuple[str, str]:
    """Obtém a URL e qualidade desejada do usuário"""
    print(f"{Colors.YELLOW}→ Qualidade disponíveis: {', '.join(SUPPORTED_QUALITIES)}{Colors.END}")
    url = input(f"{Colors.BOLD}🔗 Cole a URL do vídeo: {Colors.END}")
    quality = input(f"{Colors.BOLD}📊 Qualidade desejada [{SUPPORTED_QUALITIES[0]}]: {Colors.END}") or SUPPORTED_QUALITIES[0]
    return url, quality

def download_video(url: str, quality: str = "highest") -> Optional[str]:
    """
    Baixa o vídeo do YouTube com a qualidade especificada
    Retorna o caminho do arquivo baixado ou None em caso de erro
    """
    try:
        yt = YouTube(url)
        
        # Seleciona stream conforme qualidade escolhida
        if quality == "highest":
            stream = yt.streams.get_highest_resolution()
        elif quality == "lowest":
            stream = yt.streams.get_lowest_resolution()
        elif quality == "audio":
            stream = yt.streams.filter(only_audio=True).first()
        else:
            raise ValueError("Qualidade não suportada")

        # Efetua o download
        filename = stream.default_filename
        output_path = stream.download(output_path=VIDEOS_DIR)
        
        return output_path

    except PytubeError as e:
        print(f"{Colors.RED}❌ Erro no YouTube: {e}{Colors.END}")
    except Exception as e:
        print(f"{Colors.RED}❌ Erro inesperado: {e}{Colors.END}")
    return None

def main() -> None:
    """Função principal do programa"""
    setup_environment()
    display_banner()
    
    try:
        url, quality = get_user_input()
        
        if quality.lower() not in SUPPORTED_QUALITIES:
            print(f"{Colors.YELLOW}⚠️  Qualidade inválida. Usando 'highest' como padrão.{Colors.END}")
            quality = "highest"
        
        print(f"{Colors.BLUE}⏳ Processando...{Colors.END}")
        filepath = download_video(url, quality)
        
        if filepath:
            filename = os.path.basename(filepath)
            print(f"{Colors.GREEN}✅ Download concluído!{Colors.END}")
            print(f"{Colors.BOLD}📁 Arquivo salvo em: {os.path.abspath(filepath)}{Colors.END}")
            print(f"{Colors.GREEN}Tamanho: {os.path.getsize(filepath) / (1024*1024):.2f} MB{Colors.END}")
    
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}⚠️  Operação cancelada pelo usuário.{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()