#!/bin/bash
set -e

# Caminho dos .class recebido como argumento, padrão = robocode/robots
ROBO_DIR="${1:-robocode/robots}"

ROBOCODE_JAR="libs/robocode.jar"
PACKAGE="github"
ROBO="$PACKAGE.PrimeiroRobo"
OPONENTE="$PACKAGE.Corners" # ATENÇÃO: nome igual ao .class!

# Vai pra raiz do projeto (caso seja chamado de scripts/)
cd "$(dirname "$0")/.."

echo "==== TESTE DE BATALHA ===="
echo "Robôs testados: $ROBO vs $OPONENTE"
echo "Diretório dos .class: $ROBO_DIR/github/"

mkdir -p battle_logs

# --- Diagnóstico: mostra arquivos dos robôs antes da batalha
echo "Listando robôs no $ROBO_DIR/github/:"
ls -l "$ROBO_DIR/github/" || { echo "Robôs não encontrados!"; exit 9; }

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

# Executa a batalha (headless)
java -Xmx512M -cp "libs/*:$ROBO_DIR/" robocode.Robocode -battle battle_logs/simples.battle -nodisplay > battle_logs/resultado.txt 2>&1 || {
  echo "Erro ao executar Robocode."
  exit 2
}

echo "Resultado parcial da batalha (primeiras linhas):"
head -30 battle_logs/resultado.txt

# Checagem simples pela vitória do seu robô (ajuste se quiser outra checagem)
if grep -q "1st: $ROBO" battle_logs/resultado.txt; then
  echo "✅ $ROBO venceu a batalha!"
  exit 0
else
  echo "❌ $ROBO NÃO venceu a batalha ou nenhum robô foi executado."
  echo "Veja battle_logs/resultado.txt para investigar."
  exit 1
fi
