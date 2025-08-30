#!/bin/bash
set -e

# VARIÁVEIS DE CONFIGURAÇÃO
ROBOCODE_JAR="libs/robocode.jar" # Ajuste se necessário
PACKAGE="sample"                   # ajuste do package
ROBO="$PACKAGE.PrimeiroRobo"
OPONENTE="sample.Corners"        # Pode trocar o oponente se quiser

echo "Compilando seu robô..."
# Compila explicitamente: ajuste o caminho conforme a estrutura do seu projeto!
javac -cp "$ROBOCODE_JAR" -d robots/ src/$PACKAGE/PrimeiroRobo.java

cd "$(dirname "$0")/.." # Vai para a raiz do projeto

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

# Executa batalha e salva saída (stdout e stderr)
java -Xmx512M -cp "libs/*:robots/" robocode.Robocode -battle battle_logs/simples.battle -nodisplay > battle_logs/resultado.txt 2>&1 || {
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
