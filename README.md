# @deepwhale-cn/dsh-tool-vet

[![Listed on dsh-plugin.org](https://dsh-plugin.org/badges/listed.svg)](https://dsh-plugin.org/zh/plugins/feely0208/dsh-tool-vet)

**装第三方插件之前，先看它会动什么。**

**关键词**：工具审查 · 插件审查 · 装之前先查 · 权限 · 能力枚举 · 供应链安全 · postinstall · 恶意依赖 · 可信度

---

## 先说清楚它是什么、不是什么

**是**：装一个第三方插件/包**之前**，静态审查它**会干什么** —— 执行命令、读敏感路径、往外发数据、装的时候自动跑什么。

**不是**：
- ❌ **不是沙箱** —— 不拦截运行，只做静态审查
- ❌ **不是运行时权限审批** —— 那是另一类工具（市场里已经很多）
- ❌ **不是漏洞库比对** —— 那是 `dsh-dep-audit` 的活
- ❌ **不下「安全 / 不安全」的结论** —— 只列能力，判断留给你

**一句话分界**：**别人是门卫，这个是体检。** 门卫管进出，体检告诉你这个新来的会动什么。

与 `dsh-dep-audit` 的分界：
```
dep-audit  = 查【你自己项目】的【依赖树】
tool-vet   = 审查【一个第三方包本身】的【代码能力】
```

---

## 它查什么（6 条）

| 规则 | 查什么 | 级别 |
|---|---|---|
| `VET-INSTALL-SCRIPT` | 装了就会自动执行（`preinstall`/`install`/`postinstall`）| 🔴 |
| `VET-CRED-PATH` | 代码里出现 `~/.ssh`、`~/.aws`、`~/.npmrc` 等凭据路径 | 🔴 |
| `VET-OBFUSCATION` | 拼接执行 / 超长编码串（MITRE ATT&CK T1027）| 🔴 |
| `VET-OUTBOUND` | 会往网络上发东西 | 🟡 |
| `VET-EXEC` | 会执行外部命令 | 🟡 |
| `VET-DEP-SOURCE` | 依赖来自 registry 之外（`git:` / `http:` / `file:`）| 🟡 |

**每条都会给出：哪个文件、第几行、那行代码长什么样、依据是什么。**

---

## 安装

```bash
dsh plugin --profile web add @deepwhale-cn/dsh-tool-vet
```

## 用法

```bash
# 审查一个本地目录
dsh-tool-vet --root /path/to/some-plugin

# 看内置演示（一个「看着正常、实际会读私钥并外发」的假插件）
dsh-tool-vet --demo

# 列出规则与依据
dsh-tool-vet --list-rules

# 出 HTML 报告
dsh-tool-vet --root /path/to/some-plugin --html
```

---

## 一个真实的例子

`--demo` 审查的那个假插件，描述是「给会话加一个快速笔记面板」，看起来人畜无害。

它会：
```
🔴 装的时候就自动执行 scripts/setup.js
🔴 读 ~/.ssh/id_rsa、~/.aws/credentials、~/.npmrc
🔴 一段 base64 串还原后 new Function() 执行
🟡 catch 网络：往 telemetry.example-collector.net 发 POST
🟡 调 child_process
🟡 依赖从 git 仓库直装，绕过 npm 包名体系
```

**这六条，装之前就能看见。**

---

## 边界

- **只做静态审查** —— 代码里动态拼出来的路径、从网络拉下来的代码，它看不见
- **不判定意图** —— 「读 `.ssh`」是能力，不是罪证。一个 SSH 工具当然要读 `.ssh`，所以报出来是提示你确认，不是判定它有问题
- **覆盖不到依赖内部** —— 它审查的是这一个包自己的代码，不递归进依赖树（那是 `dep-audit` 的范围）
- **判据是「值得警惕的能力」** —— 不是「违规」。所以这里没有法条，依据是官方文档与公开的威胁模型

---

## License

MIT © 深鲸 DeepWhale
