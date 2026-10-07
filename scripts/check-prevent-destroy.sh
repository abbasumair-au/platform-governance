#!/usr/bin/env bash
# TF-9: stateful azurerm resources must declare lifecycle.prevent_destroy = true.
# Usage: check-prevent-destroy.sh <dir>
set -uo pipefail
dir="${1:-.}"
stateful='azurerm_mssql_server|azurerm_mssql_database|azurerm_postgresql_flexible_server|azurerm_key_vault|azurerm_kubernetes_cluster|azurerm_container_registry'
fail=0

while IFS= read -r f; do
  awk -v re="^resource \"($stateful)\"" -v file="$f" '
    $0 ~ re { name=$0; inres=1; found=0; depth=0 }
    inres {
      n=gsub(/\{/,"{"); m=gsub(/\}/,"}"); depth+=n-m
      if ($0 ~ /prevent_destroy[[:space:]]*=[[:space:]]*true/) found=1
      if (depth==0) {
        if (!found) { printf "FAIL TF-9: %s: %s lacks prevent_destroy = true\n", file, name; bad=1 }
        inres=0
      }
    }
    END { exit bad }
  ' "$f" || fail=1
done < <(find "$dir" -name '*.tf' -not -path '*/.terraform/*')

exit $fail
