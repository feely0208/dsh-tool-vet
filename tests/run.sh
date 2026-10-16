#!/bin/bash
set -uo pipefail
export PATH="/usr/local/bin:$PATH"
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }
echo ""; echo "  @deepwhale-cn/dsh-tool-vet · 双向验证"
echo "  ────────────────────────────────────────────────"
J=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --json 2>&1)
echo "  【正例】6 条能力规则都要在假插件上报出来"
for rid in VET-INSTALL-SCRIPT VET-CRED-PATH VET-OUTBOUND VET-EXEC VET-DEP-SOURCE VET-OBFUSCATION; do
  c=$(echo "$J" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(len([f for f in d.get('findings',[]) if f.get('ruleId')=='$rid']))
except Exception: print(0)" 2>/dev/null)
  [ "${c:-0}" -gt 0 ] && ok "$rid 报出（$c 处）" || bad "$rid 未报出"
done
echo ""; echo "  【反例】老实的插件必须 0 命中（误报是头号杀手）"
M=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${M:-1}" = "0" ] && ok "干净插件 0 命中" || bad "误报 ${M} 条"
echo ""; echo "  【溯源】每条规则必须带 source 且指得出处"
python3 - <<'PY' && ok "全部规则均有 source 且能指到出处" || bad "有规则缺 source/出处"
import json,glob,sys
for f in glob.glob('rules/*.json'):
    r=json.load(open(f,encoding='utf-8')); s=r.get('source','')
    if not s: print('缺:',r.get('id'),file=sys.stderr); sys.exit(1)
    # 真实风险类：必须能指到官方文档 / 标准 / ATT&CK 编号
    if not any(k in s for k in ('官方','标准','规范','ATT&CK','文档')):
        print('出处不可查:',r.get('id'),file=sys.stderr); sys.exit(1)
PY
echo ""; echo "  【边界】只列能力，不下"安全/不安全"结论"
# 判据：规则【标题】是对能力的描述，不能是对被扫对象的定性。
# （source 里描述攻击手法是必要的，不算违规 —— 那是「这类攻击长什么样」，不是「你这个包有问题」）
BADTITLE=$(python3 - <<'PYB'
import json, glob, sys
VERDICT = ('恶意', '不安全', '危险', '病毒', '安全')   # 对被扫对象的定性
for f in glob.glob('rules/*.json'):
    t = json.load(open(f, encoding='utf-8')).get('title', '')
    if any(w in t for w in VERDICT):
        print(t); sys.exit(0)
PYB
)
if [ -n "$BADTITLE" ]; then
  bad "规则标题出现定性措辞（只该描述能力）：$BADTITLE"
else
  ok "规则标题只描述能力，不对被扫对象下结论"
fi
echo ""; echo "  ────────────────────────────────────────────────"
echo "  通过 $PASS · 失败 $FAIL"; echo ""
[ "$FAIL" -eq 0 ] || exit 1
