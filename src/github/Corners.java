#!/bin/bash
set -e

# Mostra o diretório atual de execução para debug CI
echo "Diretório atual do runner: $(pwd)"

# Caminho dos .class recebido como argumento, padrão = robocode/robots
ROBO_DIR="${1:-robocode/robots}"
ROBOCODE_JAR="libs/robocode.jar"
PACKAGE="github"
ROBO="$PACKAGE.PrimeiroRobo"
OPONENTE="$PACKAGE.Corners" # ATENÇÃO: nome idêntico ao .class!

# Vai para a raiz do projeto (caso seja chamado de scripts/)
cd "$(dirname "$0")/.."

# Caminho absoluto dos robôs, evitando bugs na execução via CI/GitHub Actions
ABS_ROBO_DIR="$(cd "$ROBO_DIR" && pwd)"

echo "==== TESTE DE BATALHA ===="
echo "Robôs testados: $ROBO vs $OPONENTE"
echo "Diretório dos .class (relativo): $ROBO_DIR/github/"
echo "Diretório dos .class (absoluto): $ABS_ROBO_DIR/github/"

mkdir -p battle_logs

# --- Diagnóstico: mostra arquivos dos robôs antes da batalha
echo "Listando robôs em $ABS_ROBO_DIR/github/:"
ls -l "$ABS_ROBO_DIR/github/" || { echo "Robôs não encontrados!"; exit 9; }

# Cria o arquivo de configuração da batalha (.battle)
cat > battle_logs/simples.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=$ROBO,$OPONENTE
EOF

echo "Arquivo .battle gerado:"
cat battle_logs/simples.battle

# Executa a batalha (headless) - classe principal precisa encontrar os .class dos robôs!
echo "Iniciando Robocode headless com classpath: libs/*:$ABS_ROBO_DIR/"
java -Xmx512M -cp "libs/*:$ABS_ROBO_DIR/" robocode.Robocode -battle battle_logs/simples.battle -nodisplay \
    > battle_logs/resultado.txt 2>&1 || {
    echo "Erro ao executar Robocode."
    exit 2
}

echo "Resultado parcial da batalha (primeiras linhas):"
head -30 battle_logs/resultado.txt

echo "Robôs reconhecidos no log da batalha:"
grep -Eo "$PACKAGE\.[A-Za-z0-9_]+" battle_logs/resultado.txt | sort | uniq || echo "(Nenhum robô reconhecido)"

# Checagem simples pela vitória do seu robô (ajuste se quiser outra checagem)
if grep -q "1st: $ROBO" battle_logs/resultado.txt; then
    echo "✅ $ROBO venceu a batalha!"
    exit 0
else
    echo "❌ $ROBO NÃO venceu a batalha ou nenhum robô foi executado."
    echo "Veja battle_logs/resultado.txt para investigar."
    exit 1
fi
