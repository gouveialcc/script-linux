###  setup_clamav.sh  ###

ClamAV via Docker
Este script automatiza a implantação de uma solução de segurança com ClamAV rodando em container, garantindo isolamento e facilidade de manutenção. As etapas realizadas são:

1. Preparação do Ambiente
Instalação de Dependências: Instala o docker.io diretamente no host Linux.

Estrutura de Diretórios: Cria os diretórios /opt/clamav (para a base de dados de vírus) e /var/log/clamav no host para garantir persistência dos dados.

2. Provisionamento do Container
Detecção de Arquitetura: O script identifica automaticamente se o sistema é AMD64 ou ARM64 para baixar a imagem correta do Docker.

Deploy do Container: Sobe o serviço clamav/clamav-debian:1.5.2 com reinicialização automática (--restart always) e monta o sistema de arquivos raiz do host como apenas leitura (ro) no container para inspeção.

3. Configuração do Mecanismo de Scan
Script de Varredura (clam.sh): Cria e injeta um script customizado dentro do container que:

Executa o scan com baixa prioridade de CPU e I/O (nice e ionice) para evitar impacto na performance do servidor.

Filtra arquivos por tamanho (máx. 100MB) e ignora diretórios de sistema (/proc, /sys, etc.).

Gera logs datados e implementa uma política de retenção (limpeza de logs com mais de 10 dias).

4. Agendamento (Cron)
Automação Semanal: Configura automaticamente uma tarefa no crontab do host para disparar o scan todos os domingos às 05:00, executando o comando via docker exec.
