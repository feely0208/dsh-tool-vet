import { createPlugin, pkgRootFrom } from '@deepwhale-cn/dsh-guard-core/plugin';

export const { name, inject, apply } = createPlugin({
  name: 'tool-vet',
  pkgRoot: pkgRootFrom(import.meta.url),
  skillFile: 'skill/tool-vet.md',
  binFile: 'bin/cli.mjs',
  description: '装第三方插件之前，先看它会动什么',
  whenToUse: '用户要装一个不熟悉的 DSH 插件 / npm 包 / 第三方工具，想先知道它会动什么时用。'
    + '用户会说：「这个插件安全吗」「装这个东西会不会有问题」「帮我看看这个包干什么的」。',
});
