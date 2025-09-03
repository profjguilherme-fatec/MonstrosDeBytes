#!/bin/bash
set +e

mkdir -p battle_logs

# --------------- CHECKSTYLE/STATUS (já feito pelo CI) ---------------

# --------------- SPOTBUGS/STATUS (já feito pelo CI) ---------------

# --------------- CRIAÇÃO DO ARQUIVO DE BATALHA ---------------
cat > battle_logs/sample_vs_sample.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=Corners,PrimeiroRobo
EOF

echo "Rodando batalha entre seus robôs..."
java -Xmx512M -cp libs/robocode.jar robocode.Robocode -battle battle_logs/sample_vs_sample.battle -nodisplay \
    > battle_logs/sample_result.txt 2>&1 || true

echo "Resultados da batalha:"
grep -E "Corners|PrimeiroRobo" battle_logs/sample_result.txt || echo "(Nada encontrado. Algo deu errado!)"

# --------------- GERAÇÃO DO RELATÓRIO HTML ---------------
REPORT_HTML="battle_logs/report.html"
cat > "$REPORT_HTML" <<EOF
<!DOCTYPE html>
<html lang="pt-br">
<head><meta charset="UTF-8"><title>Relatório Robocode Pipeline</title></head>
<body>
  <h2>Status de Checkstyle</h2><pre>$(cat battle_logs/checkstyle_status.txt 2>/dev/null)</pre>
  <h2>Status de SpotBugs</h2><pre>$(cat battle_logs/spotbugs_status.txt 2>/dev/null)</pre>
  <h2>Status de Compilação Robocode</h2><pre>$(cat battle_logs/robocode_build_status.txt 2>/dev/null)</pre>
  <h3>Log da batalha</h3>
  <pre>
EOF
grep -E "Corners|PrimeiroRobo" battle_logs/sample_result.txt | head -40 >> "$REPORT_HTML"
cat >> "$REPORT_HTML" <<EOF
  </pre><hr>
  <small>Relatório do CI e da batalha gerado automaticamente em $(date).</small>
</body>
</html>
EOF

echo "Relatório HTML de pipeline e batalha gerado em $REPORT_HTML"
exit 0
