#!/bin/bash
set +e

mkdir -p battle_logs

# Configuração da batalha
cat > battle_logs/sample_vs_sample.battle <<EOF
robocode.battleField.width=800
robocode.battleField.height=600
robocode.battle.numRounds=3
robocode.battle.gunCoolingRate=0.1
robocode.battle.rules.inactivityTime=450
robocode.battle.hideEnemyNames=false
robocode.battle.robots=github.Corners,github.PrimeiroRobo
EOF

# Rodando a batalha
echo "Rodando batalha entre os robôs github.Corners e github.PrimeiroRobo..."
java -Xmx512M -cp libs/robocode.jar robocode.Robocode -battle battle_logs/sample_vs_sample.battle -nodisplay > battle_logs/sample_result.txt 2>&1 || true

# Salva os status para variáveis (lê os arquivos gerados por steps anteriores)
STATUS_CHECKSTYLE=$(cat battle_logs/checkstyle_status.txt 2>/dev/null || echo "N/A")
STATUS_SPOTBUGS=$(cat battle_logs/spotbugs_status.txt 2>/dev/null || echo "N/A")
STATUS_COMPILE=$(cat battle_logs/robocode_build_status.txt 2>/dev/null || echo "N/A")

# Função para interpretar status
interpreta() {
  case $1 in
    0) echo "✅ Sucesso (\`$1\`)" ;;
    1) echo "⚠️ Erro menor (\`$1\`)" ;;
    N/A) echo "❓ Não disponível" ;;
    *) echo "❌ Falhou (\`$1\`)" ;;
  esac
}

# Gera relatório markdown
REPORT_MD="battle_logs/report.md"
{
echo "# :robot: Relatório do Pipeline Robocode"
echo
echo "| Etapa                   | Status                  |"
echo "|-------------------------|-------------------------|"
echo "| **Checkstyle**          | $(interpreta $STATUS_CHECKSTYLE)    |"
echo "| **SpotBugs**            | $(interpreta $STATUS_SPOTBUGS)      |"
echo "| **Compilação Robocode** | $(interpreta $STATUS_COMPILE)       |"
echo
echo "## :crossed_swords: Log da Batalha"
echo
echo '```'
grep -E "github.Corners|github.PrimeiroRobo" battle_logs/sample_result.txt | head -40 || echo "(Nada encontrado.)"
echo '```'
echo
echo "---"
echo "<sub>Relatório gerado automaticamente em $(date '+%d/%m/%Y %H:%M')</sub>"
} > "$REPORT_MD"

echo "Relatório Markdown gerado em $REPORT_MD"
exit 0
