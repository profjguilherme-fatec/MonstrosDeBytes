#!/bin/bash
set -e

ROBOCODE_JAR="../libs/robocode.jar" # Ajuste o path conforme necessário!
ROBO="sample.PrimeiroRobo"
OPONENTE="sample.Corners"    # Você pode trocar pelo adversário que preferir

cd "$(dirname "$0")/.."      # Garante que sempre rode a partir da raiz do projeto

echo "Rodando batalha headless ($ROBO vs $OPONENTE)..."
mkdir -p battle_logs

# Cria arquivo de configuração .battle
cat > battle_logs/simples.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=$ROBO,$OPONENTE
EOF

# Roda a batalha sem interface gráfica, salva tudo em 'resultado.txt'
java -Xmx512M -cp "libs/*" robocode.Robocode -battle battle_logs/simples.battle -nodisplay > battle_logs/resultado.txt || {
    echo "Erro ao executar Robocode."
    exit 2
}

echo "Analisando resultado da batalha..."

# Procura se seu robô ficou em 1º lugar
if grep -q "1st: $ROBO" battle_logs/resultado.txt; then
  echo "✅ Seu robô venceu a batalha!"
  exit 0
else
  echo "❌ Seu robô NÃO venceu a batalha."
  exit 1
fi
