__________________________
SETUP_CLAMAV.SH
__________________________

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


__________________________
DISK.SH 
__________________________

O que o script faz?
Varredura Inteligente: Ele percorre o diretório escolhido e calcula o tamanho total de cada subpasta.

Rank de "Vilões": Organiza os resultados do maior para o menor, exibindo apenas os 20 maiores.

Alerta Visual: Usa cores para facilitar a leitura. Se o tamanho estiver em Gigabytes (G), ele destaca em vermelho; se for menor, em verde.

Estética Profissional: Exibe uma barra de progresso animada e uma tabela organizada para que os nomes dos arquivos não fiquem bagunçados na tela.

🚀 Como usar?
Existem duas formas principais de rodar o script:

1. Analisar a pasta onde você está agora:
Basta executar o script sem argumentos:
> disk.sh

2. Analisar uma pasta específica (ex: sua pasta de Usuário ou o Sistema todo):
Passe o caminho da pasta logo após o nome do script:

- Para analisar sua pasta pessoal
> disk.sh /home/seu_usuario

- Para analisar o sistema inteiro (pode pedir senha de administrador)
> disk.sh /
