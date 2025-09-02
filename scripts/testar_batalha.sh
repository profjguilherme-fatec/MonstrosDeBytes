#!/bin/bash
set -e

# Garante a criação do diretório de log
mkdir -p battle_logs

# Gera a batalha
cat > battle_logs/sample_vs_sample.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=sample.Corners,sample.Walls
EOF

echo "Rodando batalha entre sample.Corners e sample.Walls..."
java -Xmx512M -cp libs/robocode.jar robocode.Robocode -battle battle_logs/sample_vs_sample.battle -nodisplay \
    > battle_logs/sample_result.txt 2>&1

echo "Resultados da batalha:"
grep -E "sample\.(Corners|Walls)" battle_logs/sample_result.txt || echo "(Nada encontrado. Algo deu errado!)"
