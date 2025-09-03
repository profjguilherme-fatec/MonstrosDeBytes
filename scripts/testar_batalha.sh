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

# ----------- GERAÇÃO DO RELATÓRIO HTML -----------
REPORT_HTML="battle_logs/report.html"

# Cabeçalho HTML
cat > "$REPORT_HTML" <<EOF
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <title>Relatório da Batalha Robocode</title>
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
  <h1>Relatório da Batalha Robocode</h1>
  <b>Robôs:</b> sample.Corners vs sample.Walls<br>
  <b>Rounds:</b> 3<br><br>
  <h2>Resumo dos Resultados</h2>
  <table>
    <tr>
      <th>Robô</th>
      <th>Pontuação (estimada)</th>
      <th>Comentários</th>
    </tr>
EOF

# Coleta pontuação dos logs (*adapte conforme o formato real dos seus logs; este é exemplo*)
SCORE_CORNERS=$(grep "sample.Corners" battle_logs/sample_result.txt | grep "score" | tail -1 | grep -Eo "[0-9]+")
SCORE_WALLS=$(grep "sample.Walls" battle_logs/sample_result.txt | grep "score" | tail -1 | grep -Eo "[0-9]+")

[[ -z "$SCORE_CORNERS" ]] && SCORE_CORNERS="N/A"
[[ -z "$SCORE_WALLS" ]] && SCORE_WALLS="N/A"

cat >> "$REPORT_HTML" <<EOF
    <tr>
      <td>sample.Corners</td>
      <td>$SCORE_CORNERS</td>
      <td></td>
    </tr>
    <tr>
      <td>sample.Walls</td>
      <td>$SCORE_WALLS</td>
      <td></td>
    </tr>
  </table>
  <h2>Principais eventos do log</h2>
  <pre>
EOF

# Adiciona até 40 linhas relevantes do log
grep -E "sample\.(Corners|Walls)" battle_logs/sample_result.txt | head -40 >> "$REPORT_HTML"

cat >> "$REPORT_HTML" <<EOF
  </pre>
  <hr>
  <small>Relatório gerado automaticamente por testar_batalha.sh<br>
  $(date)</small>
</body>
</html>
EOF

echo "Relatório HTML de batalha gerado em $REPORT_HTML"
