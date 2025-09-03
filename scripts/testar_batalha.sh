#!/bin/bash
set +e

# --------------- PREPARAÇÃO ---------------
mkdir -p battle_logs

# --------------- COMPILAR ROBÔS ---------------
javac MonstrosDeBytes/robocode/robots/*.java -d MonstrosDeBytes/robocode/robots/

# --------------- CHECKSTYLE ---------------
checkstyle -c /google_checks.xml MonstrosDeBytes/robocode/robots/*.java
echo $? > checkstyle_status
cp checkstyle_status battle_logs/checkstyle_status.txt

# --------------- SPOTBUGS ---------------
spotbugs -textUI -effort:min MonstrosDeBytes/robocode/robots/
echo $? > spotbugs_status
cp spotbugs_status battle_logs/spotbugs_status.txt

# (Opcional: build status pode ser só o compilador acima)
echo $? > robocode_build_status
cp robocode_build_status battle_logs/robocode_build_status.txt

# --------------- CRIAÇÃO DO ARQUIVO DE BATALHA ---------------
cat > battle_logs/sample_vs_sample.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=MonstrosDeBytes.robocode.robots.MeuRobo1,MonstrosDeBytes.robocode.robots.MeuRobo2
EOF

echo "Rodando batalha entre seus robôs..."
java -Xmx512M -cp libs/robocode.jar robocode.Robocode -battle battle_logs/sample_vs_sample.battle -nodisplay \
    > battle_logs/sample_result.txt 2>&1 || true

echo "Resultados da batalha:"
grep -E "MeuRobo1|MeuRobo2" battle_logs/sample_result.txt || echo "(Nada encontrado. Algo deu errado!)"

# --------------- GERAÇÃO DO RELATÓRIO HTML ---------------
REPORT_HTML="battle_logs/report.html"
function parse_status {
  local code="$1"
  [[ "$code" == "0" ]] && echo "Sucesso" || ([[ "$code" == "N/A" ]] && echo "Não executado" || echo "Falha (código $code)")
}
CHECKSTYLE_STATUS=$(cat battle_logs/checkstyle_status.txt 2>/dev/null || echo "N/A")
SPOTBUGS_STATUS=$(cat battle_logs/spotbugs_status.txt 2>/dev/null || echo "N/A")
ROBOCODE_BUILD_STATUS=$(cat battle_logs/robocode_build_status.txt 2>/dev/null || echo "N/A")

# Pega pontuação dos robôs
SCORE_ROBO1=$(grep "MeuRobo1" battle_logs/sample_result.txt | grep "score" | tail -1 | grep -Eo "[0-9]+")
SCORE_ROBO2=$(grep "MeuRobo2" battle_logs/sample_result.txt | grep "score" | tail -1 | grep -Eo "[0-9]+")
[[ -z "$SCORE_ROBO1" ]] && SCORE_ROBO1="N/A"
[[ -z "$SCORE_ROBO2" ]] && SCORE_ROBO2="N/A"

cat > "$REPORT_HTML" <<EOF
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <title>Relatório Integrado do CI - Robocode</title>
  <style>
    body { font-family: Arial, sans-serif; margin:40px;}
    h1 { color: #19406D; }
    table { border-collapse: collapse; margin-top: 16px; }
    th, td { border: 1px solid #bbb; padding: 8px 16px; }
    th { background: #eee; }
    pre { background: #f0f0f0; padding:12px; border-radius:6px;}
  </style>
</head>
<body>
  <h1>Relatório Integrado do Pipeline</h1>
  <h2>Status dos Jobs de Qualidade</h2>
  <table>
    <tr><th>Tarefa</th><th>Status</th></tr>
    <tr><td>Checkstyle</td><td>$(parse_status "$CHECKSTYLE_STATUS")</td></tr>
    <tr><td>SpotBugs</td><td>$(parse_status "$SPOTBUGS_STATUS")</td></tr>
    <tr><td>Compilação Robocode</td><td>$(parse_status "$ROBOCODE_BUILD_STATUS")</td></tr>
  </table>
  <hr>
  <h2>Relatório da Batalha Robocode</h2>
  <b>Robôs:</b> MeuRobo1 vs MeuRobo2<br>
  <b>Rounds:</b> 3<br><br>
  <h3>Resumo dos Resultados</h3>
  <table>
    <tr>
      <th>Robô</th>
      <th>Pontuação (estimada)</th>
    </tr>
    <tr>
      <td>MeuRobo1</td>
      <td>$SCORE_ROBO1</td>
    </tr>
    <tr>
      <td>MeuRobo2</td>
      <td>$SCORE_ROBO2</td>
    </tr>
  </table>
  <h3>Principais eventos do log</h3>
  <pre>
EOF
grep -E "MeuRobo1|MeuRobo2" battle_logs/sample_result.txt | head -40 >> "$REPORT_HTML"
cat >> "$REPORT_HTML" <<EOF
  </pre>
  <hr>
  <small>Relatório do CI e da batalha gerado automaticamente em $(date).</small>
</body>
</html>
EOF

echo "Relatório HTML de pipeline e batalha gerado em $REPORT_HTML"

exit 0
