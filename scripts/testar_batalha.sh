#!/bin/bash
set -e

# Permite passar o caminho dos .class como argumento, padrão = robocode/robots/
ROBO_DIR="${1:-robocode/robots}"

ROBOCODE_JAR="libs/robocode.jar"
PACKAGE="github"
ROBO="$PACKAGE.PrimeiroRobo"
OPONENTE="$PACKAGE.Cornes"  # Ajuste para Corners se for o correto!

# Vai para a raiz do projeto (caso o script seja chamado de scripts/)
cd "$(dirname "$0")/.."

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

# Verifica se os .class estão onde devem estar
echo "Listando arquivos em $ROBO_DIR/github/ para debug:"
ls -l "$ROBO_DIR/github/" || { echo "Robôs não encontrados em $ROBO_DIR/github/"; exit 7; }

# Executa o Robocode, inclui o caminho correto dos .class no classpath
java -Xmx512M -cp "libs/*:$ROBO_DIR/" robocode.Robocode -battle battle_logs/simples.battle -nodisplay > battle_logs/resultado.txt 2>&1 || {
  echo "Erro ao executar Robocode."
  exit 2
}

echo "Analisando resultado da batalha..."
echo "------ INÍCIO DO RESULTADO ------"
head -30 battle_logs/resultado.txt
echo "------ FIM DO RESULTADO ------"

# Checa se seu robô ficou em 1º lugar (linha deve bater EXATAMENTE!)
if grep -q "1st: $ROBO" battle_logs/resultado.txt; then
  echo "✅ Seu robô venceu a batalha!"
  exit 0
else
  echo "❌ Seu robô NÃO venceu a batalha."
  echo "Sugestão: confira o conteúdo completo em battle_logs/resultado.txt para investigar possíveis causas."
  exit 1
fi
